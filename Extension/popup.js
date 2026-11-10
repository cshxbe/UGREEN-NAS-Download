const $=id=>document.getElementById(id);
const status=(text,state="")=>{$("status").textContent=text;$("status").dataset.state=state;};
browser.storage.local.get("enabled").then(s=>$("enabled").checked=s.enabled===true);
$("enabled").addEventListener("change",()=>browser.storage.local.set({enabled:$("enabled").checked}));
$("options").addEventListener("click",()=>browser.runtime.openOptionsPage());
$("send").addEventListener("click",async()=>{const link=$("link").value.trim();if(!link){$("link").focus();return;}$("send").disabled=true;status((browser.i18n?.getMessage("ui_3b732d654b2e")||"Envoi au NAS…"));try{const r=await browser.runtime.sendMessage({kind:"sendLink",link});status(r?.message||r?.error||(browser.i18n?.getMessage("ui_df615a99851a")||"Vérifiez le NAS avant de réessayer."),r?.ok?"success":"error");}catch{status((browser.i18n?.getMessage("ui_56e0d2482f10")||"Aucune confirmation. Vérifiez le NAS avant de réessayer."),"error");}finally{$("send").disabled=false;}});
$("link").addEventListener("keydown",event=>{if(event.key==="Enter")$("send").click();});
async function updatePageIndicator(){
 const indicator=$("page-indicator");
 try{
  const [tab]=await browser.tabs.query({active:true,currentWindow:true});
  if(!tab||(tab.url&&!/^https?:/.test(tab.url))){indicator.textContent=(browser.i18n?.getMessage("ui_c66fb56b416f")||"Extension indisponible sur cette page");indicator.dataset.state="unavailable";return;}
  const r=await browser.tabs.sendMessage(tab.id,{kind:"interceptionStatus"},{frameId:0});
  indicator.dataset.state=r?.enabled?"ready":"inactive";
  indicator.textContent=!r?(browser.i18n?.getMessage("ui_cb8d924d14fd")||"Rechargez cette page pour activer l’extension"):!r.enabled?(browser.i18n?.getMessage("ui_d143da43aff6")||"Envoi automatique désactivé"):r.bridgeAck?(browser.i18n?.getMessage("ui_4b695c7c1ff4")||"Extension active sur ce site"):(browser.i18n?.getMessage("ui_8c14f6145e6e")||"Extension active · liens directs");
 }catch{indicator.dataset.state="unavailable";indicator.textContent=(browser.i18n?.getMessage("ui_cd4d0abee3d3")||"Accès à ce site non autorisé ou page à recharger");}
}
updatePageIndicator();
browser.storage.onChanged.addListener(changes=>{if(changes.enabled)setTimeout(updatePageIndicator,100);});
browser.tabs.onActivated.addListener(updatePageIndicator);
browser.tabs.onUpdated.addListener((_id,change)=>{if(change.status==="complete")updatePageIndicator();});


function transferSize(value){if(!Number.isFinite(value)||value<0)return"—";if(value===0)return"0 o";const units=["o","Ko","Mo","Go","To"],i=Math.min(4,Math.max(0,Math.floor(Math.log(value)/Math.log(1024))));return new Intl.NumberFormat(browser.i18n?.getUILanguage()||"fr",{maximumFractionDigits:i===0?0:1}).format(value/1024**i)+" "+units[i];}
function taskState(state){return{1:(browser.i18n?.getMessage("ui_2f6c8477e92b")||"En attente"),2:(browser.i18n?.getMessage("ui_38858cd588e0")||"Téléchargement"),4:(browser.i18n?.getMessage("ui_239c064e0d40")||"En pause"),5:"Erreur",6:(browser.i18n?.getMessage("ui_e62e17c13421")||"Recherche de sources"),7:(browser.i18n?.getMessage("ui_97a4b5570c16")||"Vérification")}[state]||(browser.i18n?.getMessage("ui_797f5dcd0217")||"En cours");}
let downloadsTimer=null,downloadsLoading=false,downloadsClosed=false,hasDownloadsSnapshot=false;
function renderDownloads(tasks){
 const list=$("downloads-list");list.replaceChildren();$("download-count").textContent=tasks.length?String(tasks.length):"";
 for(const task of tasks){
  const row=document.createElement("article");row.className="download-task";
  const heading=document.createElement("div");heading.className="task-heading";
  const name=document.createElement("h3");name.textContent=task.name;name.title=task.name;
  const percent=document.createElement("span");percent.className="task-percent";const known=Number.isFinite(task.progress);percent.textContent=known?new Intl.NumberFormat(browser.i18n?.getUILanguage()||"fr",{maximumFractionDigits:1}).format(task.progress)+" %":"—";heading.append(name,percent);
  const bar=document.createElement("progress");bar.max=100;if(known)bar.value=task.progress;bar.setAttribute("aria-label",(browser.i18n?.getMessage("ui_bf5f1a5e561a")||"Progression de {name}").replace("{name}",()=>task.name));
  const meta=document.createElement("div");meta.className="task-meta";
  const state=document.createElement("span");state.textContent=taskState(task.state);if(task.state===5)state.className="task-error";
  const speed=document.createElement("span");speed.className="task-speed";speed.textContent=transferSize(task.speed)+"/s";meta.append(state,speed);
  const size=document.createElement("p");size.className="task-size";size.textContent=task.size>0?(browser.i18n?.getMessage("ui_fcd28038ac90")||"{received} sur {total}").replace("{received}",()=>transferSize(task.downloaded)).replace("{total}",()=>transferSize(task.size)):transferSize(task.downloaded)+(browser.i18n?.getMessage("ui_01f19353c67f")||" reçus");
  row.append(heading,bar,meta,size);list.append(row);
 }
}
async function refreshDownloads(){
 if(downloadsLoading||downloadsClosed||document.hidden)return;
 clearTimeout(downloadsTimer);downloadsLoading=true;$("refresh-downloads").disabled=true;
 try{
  const result=await browser.runtime.sendMessage({kind:"listDownloads"});
  if(downloadsClosed)return;
  if(result?.busy){$("downloads-notice").textContent=hasDownloadsSnapshot?"":(browser.i18n?.getMessage("ui_a8b51d2ae9ee")||"Le NAS traite une autre opération…");return;}
  if(!result?.ok)throw new Error(result?.error||(browser.i18n?.getMessage("ui_e43026bf1415")||"Réponse du NAS indisponible."));
  if(!Array.isArray(result.downloads))throw new Error((browser.i18n?.getMessage("ui_62f9e34d1cb3")||"Liste des téléchargements indisponible."));
  renderDownloads(result.downloads);hasDownloadsSnapshot=true;
  $("downloads-notice").textContent=result.truncated?(browser.i18n?.getMessage("ui_dcc71329139f")||"Liste partielle : le NAS contient plus de 10 000 tâches."):result.downloads.length?"":(browser.i18n?.getMessage("ui_6d5a188afe25")||"Aucun téléchargement en cours.");
  $("downloads-updated").textContent=(browser.i18n?.getMessage("ui_fa6ca0863a17")||"Actualisé à ")+new Date().toLocaleTimeString(browser.i18n?.getUILanguage()||"fr",{hour:"2-digit",minute:"2-digit",second:"2-digit"});
 }catch(error){if(!downloadsClosed)$("downloads-notice").textContent=(hasDownloadsSnapshot?(browser.i18n?.getMessage("ui_cca90e72b30f")||"Mise à jour interrompue. "):"")+(error?.message||(browser.i18n?.getMessage("ui_36a1cad0f5a2")||"NAS inaccessible."));}
 finally{downloadsLoading=false;if(!downloadsClosed){$("refresh-downloads").disabled=false;downloadsTimer=setTimeout(refreshDownloads,3500);}}
}
$("refresh-downloads").addEventListener("click",refreshDownloads);
window.addEventListener("pagehide",()=>{downloadsClosed=true;clearTimeout(downloadsTimer);});
document.addEventListener("visibilitychange",()=>{clearTimeout(downloadsTimer);if(!document.hidden)refreshDownloads();});
refreshDownloads();


browser.storage.local.get("lastContextResult").then(s=>{const r=s.lastContextResult;if(r&&Date.now()-r.date<15*60*1000)status((browser.i18n?.getMessage("ui_3515c16c8e2f")||"Dernier envoi par clic droit : ")+r.text,r.ok?"success":"error");});
browser.browserAction.setBadgeText({text:""}).catch(()=>{});

function filenameStatus(value){$("filename-status").textContent=value?(browser.i18n?.getMessage("ui_0f218cb7d56c")||"Nom du fichier à vérifier : ")+value:"";}
browser.storage.local.get("filenameError").then(s=>filenameStatus(s.filenameError));
browser.storage.onChanged.addListener(changes=>{if(changes.filenameError)filenameStatus(changes.filenameError.newValue);});
