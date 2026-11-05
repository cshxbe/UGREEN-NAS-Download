const $=id=>document.getElementById(id);
const status=(text,state="")=>{$("status").textContent=text;$("status").dataset.state=state;};
browser.storage.local.get("enabled").then(s=>$("enabled").checked=s.enabled===true);
$("enabled").addEventListener("change",()=>browser.storage.local.set({enabled:$("enabled").checked}));
$("options").addEventListener("click",()=>browser.runtime.openOptionsPage());
$("send").addEventListener("click",async()=>{const link=$("link").value.trim();if(!link){$("link").focus();return;}$("send").disabled=true;status("Envoi au NAS…");try{const r=await browser.runtime.sendMessage({kind:"sendLink",link});status(r?.message||r?.error||"Vérifiez le NAS avant de réessayer.",r?.ok?"success":"error");}catch{status("Aucune confirmation. Vérifiez le NAS avant de réessayer.","error");}finally{$("send").disabled=false;}});
$("link").addEventListener("keydown",event=>{if(event.key==="Enter")$("send").click();});
async function updatePageIndicator(){
 const indicator=$("page-indicator");
 try{
  const [tab]=await browser.tabs.query({active:true,currentWindow:true});
  if(!tab||(tab.url&&!/^https?:/.test(tab.url))){indicator.textContent="Extension indisponible sur cette page";indicator.dataset.state="unavailable";return;}
  const r=await browser.tabs.sendMessage(tab.id,{kind:"interceptionStatus"},{frameId:0});
  indicator.dataset.state=r?.enabled?"ready":"inactive";
  indicator.textContent=!r?"Rechargez cette page pour activer l’extension":!r.enabled?"Envoi automatique désactivé":r.bridgeAck?"Extension active sur ce site":"Extension active · liens directs";
 }catch{indicator.dataset.state="unavailable";indicator.textContent="Accès à ce site non autorisé ou page à recharger";}
}
updatePageIndicator();
browser.storage.onChanged.addListener(changes=>{if(changes.enabled)setTimeout(updatePageIndicator,100);});
browser.tabs.onActivated.addListener(updatePageIndicator);
browser.tabs.onUpdated.addListener((_id,change)=>{if(change.status==="complete")updatePageIndicator();});


function transferSize(value){if(!Number.isFinite(value)||value<0)return"—";if(value===0)return"0 o";const units=["o","Ko","Mo","Go","To"],i=Math.min(4,Math.max(0,Math.floor(Math.log(value)/Math.log(1024))));return new Intl.NumberFormat("fr-FR",{maximumFractionDigits:i===0?0:1}).format(value/1024**i)+" "+units[i];}
function taskState(state){return{1:"En attente",2:"Téléchargement",4:"En pause",5:"Erreur",6:"Recherche de sources",7:"Vérification"}[state]||"En cours";}
let downloadsTimer=null,downloadsLoading=false,downloadsClosed=false,hasDownloadsSnapshot=false;
function renderDownloads(tasks){
 const list=$("downloads-list");list.replaceChildren();$("download-count").textContent=tasks.length?String(tasks.length):"";
 for(const task of tasks){
  const row=document.createElement("article");row.className="download-task";
  const heading=document.createElement("div");heading.className="task-heading";
  const name=document.createElement("h3");name.textContent=task.name;name.title=task.name;
  const percent=document.createElement("span");percent.className="task-percent";const known=Number.isFinite(task.progress);percent.textContent=known?new Intl.NumberFormat("fr-FR",{maximumFractionDigits:1}).format(task.progress)+" %":"—";heading.append(name,percent);
  const bar=document.createElement("progress");bar.max=100;if(known)bar.value=task.progress;bar.setAttribute("aria-label",`Progression de ${task.name}`);
  const meta=document.createElement("div");meta.className="task-meta";
  const state=document.createElement("span");state.textContent=taskState(task.state);if(task.state===5)state.className="task-error";
  const speed=document.createElement("span");speed.className="task-speed";speed.textContent=transferSize(task.speed)+"/s";meta.append(state,speed);
  const size=document.createElement("p");size.className="task-size";size.textContent=task.size>0?`${transferSize(task.downloaded)} sur ${transferSize(task.size)}`:transferSize(task.downloaded)+" reçus";
  row.append(heading,bar,meta,size);list.append(row);
 }
}
async function refreshDownloads(){
 if(downloadsLoading||downloadsClosed||document.hidden)return;
 clearTimeout(downloadsTimer);downloadsLoading=true;$("refresh-downloads").disabled=true;
 try{
  const result=await browser.runtime.sendMessage({kind:"listDownloads"});
  if(downloadsClosed)return;
  if(result?.busy){$("downloads-notice").textContent=hasDownloadsSnapshot?"":"Le NAS traite une autre opération…";return;}
  if(!result?.ok)throw new Error(result?.error||"Réponse du NAS indisponible.");
  if(!Array.isArray(result.downloads))throw new Error("Liste des téléchargements indisponible.");
  renderDownloads(result.downloads);hasDownloadsSnapshot=true;
  $("downloads-notice").textContent=result.truncated?"Liste partielle : le NAS contient plus de 10 000 tâches.":result.downloads.length?"":"Aucun téléchargement en cours.";
  $("downloads-updated").textContent="Actualisé à "+new Date().toLocaleTimeString("fr-FR",{hour:"2-digit",minute:"2-digit",second:"2-digit"});
 }catch(error){if(!downloadsClosed)$("downloads-notice").textContent=(hasDownloadsSnapshot?"Mise à jour interrompue. ":"")+(error?.message||"NAS inaccessible.");}
 finally{downloadsLoading=false;if(!downloadsClosed){$("refresh-downloads").disabled=false;downloadsTimer=setTimeout(refreshDownloads,3500);}}
}
$("refresh-downloads").addEventListener("click",refreshDownloads);
window.addEventListener("pagehide",()=>{downloadsClosed=true;clearTimeout(downloadsTimer);});
document.addEventListener("visibilitychange",()=>{clearTimeout(downloadsTimer);if(!document.hidden)refreshDownloads();});
refreshDownloads();


browser.storage.local.get("lastContextResult").then(s=>{const r=s.lastContextResult;if(r&&Date.now()-r.date<15*60*1000)status("Dernier envoi par clic droit : "+r.text,r.ok?"success":"error");});
browser.browserAction.setBadgeText({text:""}).catch(()=>{});

function filenameStatus(value){$("filename-status").textContent=value?"Nom du fichier à vérifier : "+value:"";}
browser.storage.local.get("filenameError").then(s=>filenameStatus(s.filenameError));
browser.storage.onChanged.addListener(changes=>{if(changes.filenameError)filenameStatus(changes.filenameError.newValue);});
