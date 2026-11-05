"use strict";
const APP="com.example.UGREENNASDownload";
let sending=false;
const internal=sender=>["popup.html","options.html"].some(p=>sender.url===browser.runtime.getURL(p));
// Serialize native requests so a monitoring poll cannot reject a user-initiated download.
let nativeTail=Promise.resolve();
const native=message=>{const task=nativeTail.then(()=>browser.runtime.sendNativeMessage(APP,message));nativeTail=task.catch(()=>{});return task;};
// Keep at most one scheduled request of each kind while the NAS is slow.
const pendingPolls=new Set();
async function pollNative(command){
 if(pendingPolls.has(command))return{ok:false,busy:true};
 pendingPolls.add(command);
 try{return await native({command});}finally{pendingPolls.delete(command);}
}
const CONTEXT_DOWNLOAD="download-on-nas";
let menuInstallation;
function installContextMenu(){
 if(!menuInstallation)menuInstallation=browser.contextMenus.removeAll().then(()=>browser.contextMenus.create({id:CONTEXT_DOWNLOAD,title:"T\u00e9l\u00e9charger sur le NAS",contexts:["link","image","video","audio"]}));
 return menuInstallation;
}
installContextMenu().catch(()=>{});
function downloadURL(info){
 // A linked image may have srcUrl without mediaType in Safari. Never let
 // the enclosing gallery/article link replace the selected media resource.
 const value=info.srcUrl || (info.mediaType ? null : info.linkUrl);
 if(typeof value!=="string"||value.length>65536||/[\r\n\0]/.test(value))throw new Error("Aucun lien de t\u00e9l\u00e9chargement utilisable.");
 let url;try{url=new URL(value);}catch{throw new Error("Lien de t\u00e9l\u00e9chargement invalide.");}
 if(!["http:","https:","magnet:"].includes(url.protocol))throw new Error("Ce fichier est g\u00e9n\u00e9r\u00e9 dans Safari ou prot\u00e9g\u00e9. Le NAS a besoin d\u2019un lien HTTP ou HTTPS directement accessible.");
 if(url.username||url.password)throw new Error("Les liens contenant un identifiant ou un mot de passe ne sont pas accept\u00e9s.");
 return value;
}
async function contextFeedback(info,tab,result){
 await browser.storage.local.set({lastContextResult:{ok:result.ok===true,text:result.message||result.error||"Envoi non confirm\u00e9.",date:Date.now()}});
 try{await browser.browserAction.setBadgeText({text:result.ok?"\u2713":"!"});}catch{}
 if(Number.isInteger(tab?.id))try{await browser.tabs.sendMessage(tab.id,{kind:"contextDownloadResult",result},{frameId:info.frameId??0});}catch{}
}
browser.contextMenus.onClicked.addListener(async(info,tab)=>{
 if(info.menuItemId!==CONTEXT_DOWNLOAD)return;
 if(sending){await contextFeedback(info,tab,{ok:false,error:"Un envoi est d\u00e9j\u00e0 en cours. R\u00e9essayez dans quelques instants."});return;}
 sending=true;
 try{
  const link=downloadURL(info);
  const result=await native({command:"sendDownload",link});
  if(result?.needsSetup)await browser.runtime.openOptionsPage();
  await contextFeedback(info,tab,result||{ok:false,error:"Aucune confirmation du NAS. V\u00e9rifiez ses t\u00e2ches avant de r\u00e9essayer."});
 }catch(error){await contextFeedback(info,tab,{ok:false,error:error?.message||"Envoi non confirm\u00e9. V\u00e9rifiez les t\u00e2ches du NAS."});}
 finally{sending=false;}
});
async function restoreAlarms(){
 const s=await browser.storage.local.get("downloadNotifications");
 browser.alarms.create("nas-session",{periodInMinutes:10});
 browser.alarms.create("nas-filenames",{periodInMinutes:0.5});
 if(s.downloadNotifications===true)browser.alarms.create("nas-downloads",{periodInMinutes:0.5});
 else await browser.alarms.clear("nas-downloads");
}
browser.runtime.onInstalled.addListener(async details=>{await Promise.all([restoreAlarms(),installContextMenu()]);if(details?.reason==="install")await browser.runtime.openOptionsPage();});
browser.runtime.onStartup.addListener(()=>restoreAlarms());
// Alarms can disappear when Safari unloads an extension during an update or a rename.
// Check on every background-page launch without resetting an existing alarm's schedule.
(async()=>{const alarm=await browser.alarms.get("nas-downloads");const s=await browser.storage.local.get("downloadNotifications");if(s.downloadNotifications===true&&!alarm)browser.alarms.create("nas-downloads",{periodInMinutes:0.5});})().catch(()=>{});
browser.alarms.onAlarm.addListener(async alarm=>{
 if(alarm.name==="nas-filenames"&&!sending){const result=await pollNative("labelDownloads").catch(()=>({ok:false,error:"Connexion au NAS indisponible pour corriger le nom."}));if(!result?.busy)await browser.storage.local.set({filenameError:result?.ok?"":result?.error||"Correction du nom en attente."});}
 if(alarm.name==="nas-session")await pollNative("heartbeat").catch(()=>{});
 if(alarm.name==="nas-downloads"&&!sending){
  const s=await browser.storage.local.get("downloadNotifications");
  if(s.downloadNotifications){
   const result=await pollNative("monitorDownloads").catch(()=>({ok:false,error:"Connexion aux notifications indisponible."}));
   if(!result?.busy)await browser.storage.local.set({notificationError:result?.ok?"":result?.error||"Suivi des t\u00e9l\u00e9chargements indisponible.",...(result?.ok?{lastNotificationCheck:Date.now()}:{})});
  }
 }
});
browser.runtime.onMessage.addListener(async(message,sender)=>{
  const own=internal(sender);
  if(message?.kind==="installBridge") {
    if(!sender.tab || !/^https?:/.test(sender.url||""))return;
    try{await browser.scripting.executeScript({target:{tabId:sender.tab.id,frameIds:[sender.frameId??0]},world:"MAIN",files:["page-bridge.js"]});return{ok:true};}catch(e){return{ok:false,error:String(e?.message||e).slice(0,300)};}
  }
  if(message?.kind==="setDownloadNotifications") {
    if(sender.url!==browser.runtime.getURL("options.html")||typeof message.enabled!=="boolean")return;
    if(!message.enabled){const result=await native({command:"disableNotifications"}).catch(()=>({ok:false,error:"Modification des notifications impossible."}));if(!result?.ok)return result||{ok:false,error:"Modification non confirmée."};await browser.storage.local.set({downloadNotifications:false,notificationError:""});await browser.alarms.clear("nas-downloads");return{ok:true};}
    const result=await native({command:"enableNotifications"}).catch(()=>({ok:false,error:"Notifications indisponibles."}));
    if(result?.ok){await browser.storage.local.set({downloadNotifications:true,notificationError:""});browser.alarms.create("nas-downloads",{periodInMinutes:0.5});await native({command:"monitorDownloads"}).catch(()=>{});}
    return result;
  }
  if(message?.kind==="listDownloads") {
    if(sender.url!==browser.runtime.getURL("popup.html"))return;
    if(sending)return{ok:false,busy:true};
    try{return await native({command:"downloads"});}catch{return{ok:false,error:"Connexion au NAS indisponible."};}
  }
  if(message?.kind==="nativeOptions") {
    if(!own || sender.url!==browser.runtime.getURL("options.html")) return;
    if(!["status","probe","configure","forget","notificationStatus","testNotification","discover"].includes(message.payload?.command)) return;
    try{return await native(message.payload);}catch{return{ok:false,error:"Connexion au module Mac impossible."};}
  }
  if(!["sendLink","sendTorrent"].includes(message?.kind) || (!own && !(sender.tab && /^https?:/.test(sender.url||""))))return;
  if(sending)return{ok:false,error:"Un envoi est d\u00e9j\u00e0 en cours."};
  sending=true;
  try{
    const s=await browser.storage.local.get("enabled");if(!own && s.enabled!==true)return{ok:false,error:"Interception d\u00e9sactiv\u00e9e."};
    if(message.kind==="sendTorrent") {
      if(own || !sender.tab || typeof message.data!=="string" || message.data.length>699052)return{ok:false,error:"Torrent ou origine non autoris\u00e9s."};
      const result=await native({command:"sendTorrent",data:message.data});
      if(result?.needsSetup)await browser.runtime.openOptionsPage();
      return result;
    }
    if(typeof message.link!=="string"||message.link.length>65536)return{ok:false,error:"Lien invalide."};
    const result=await native({command:sender.url===browser.runtime.getURL("popup.html")?"sendDownload":"send",link:message.link});
    if(result?.needsSetup)await browser.runtime.openOptionsPage();
    return result;
  }catch{return{ok:false,error:"Aucune confirmation du NAS. V\u00e9rifiez les t\u00e2ches avant de r\u00e9essayer."};}
  finally{sending=false;}
});

browser.alarms.get("nas-filenames").then(a=>{if(!a)browser.alarms.create("nas-filenames",{periodInMinutes:0.5});}).catch(()=>{});
