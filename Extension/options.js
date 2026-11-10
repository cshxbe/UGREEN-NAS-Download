const $=id=>document.getElementById(id);
const call=payload=>browser.runtime.sendMessage({kind:"nativeOptions",payload});
let candidate=null;
function reset(){candidate=null;$("trust").checked=false;$("trust").disabled=true;$("save").disabled=true;$("fingerprint").textContent="";}
$("address").addEventListener("input",reset);
call({command:"status"}).then(r=>{if(r?.configured){for(const k of ["address","username","saveDir"])$(k).value=r[k];$("password").placeholder=(browser.i18n?.getMessage("ui_414fcf8c8cb7")||"Laisser vide pour conserver le mot de passe actuel");$("status").textContent=(browser.i18n?.getMessage("ui_141de5281f3f")||"Compte configuré. Session et identifiants conservés dans le Trousseau.");}}).catch(()=>$("status").textContent=(browser.i18n?.getMessage("ui_26d832931702")||"Ouvrez l’application Mac puis réessayez."));
$("probe").addEventListener("click",async()=>{reset();$("probe").disabled=true;$("status").textContent=(browser.i18n?.getMessage("ui_ab13d42df210")||"Lecture du certificat, sans transmission d’identifiants…");try{const r=await call({command:"probe",address:$("address").value.trim()});if(!r?.ok)throw new Error(r?.error||(browser.i18n?.getMessage("ui_36a1cad0f5a2")||"NAS inaccessible."));candidate=r.candidate;$("fingerprint").textContent=(browser.i18n?.getMessage("ui_e8c9f22114cb")||"SHA-256 : ")+r.fingerprint.match(/.{1,2}/g).join(":");$("trust").disabled=false;$("status").textContent=(browser.i18n?.getMessage("ui_1bdda3a5e0a1")||"Vérifiez l’empreinte, puis confirmez le NAS.");}catch(e){$("status").textContent=e.message;}finally{$("probe").disabled=false;}});
$("trust").addEventListener("change",()=>$("save").disabled=!$("trust").checked);
$("config").addEventListener("submit",async e=>{e.preventDefault();if(!candidate||!$("trust").checked)return;$("save").disabled=true;$("status").textContent=(browser.i18n?.getMessage("ui_4122652cdf72")||"Test de connexion au NAS…");try{const r=await call({command:"configure",candidate,address:$("address").value.trim(),username:$("username").value.trim(),password:$("password").value,otp:$("otp").value.trim(),trustDevice:$("trustDevice").checked,saveDir:$("saveDir").value.trim()});$("password").value="";$("otp").value="";reset();$("status").textContent=r?.message||r?.error||(browser.i18n?.getMessage("ui_03000c00b0b7")||"Connexion non confirmée.");}catch{$("password").value="";$("otp").value="";reset();$("status").textContent=(browser.i18n?.getMessage("ui_d8bda67860cd")||"Connexion non confirmée. Vérifiez le NAS et recommencez.");}});
$("forget").addEventListener("click",async()=>{if(!confirm((browser.i18n?.getMessage("ui_27fd2a5f456f")||"Supprimer les identifiants et la session du Trousseau pour ce profil Safari ?")))return;const r=await call({command:"forget"});if(r?.ok){$("password").value="";$("otp").value="";reset();$("status").textContent=(browser.i18n?.getMessage("ui_b7356b338117")||"Compte oublié.");}else $("status").textContent=r?.error||(browser.i18n?.getMessage("ui_29871f14bdb5")||"Suppression impossible.");});

let notificationsEnabled=false;
browser.storage.local.get("downloadNotifications").then(s=>{notificationsEnabled=s.downloadNotifications===true;$("notify").checked=notificationsEnabled;$("notify").disabled=false;}).catch(()=>{$("notification-status").textContent=(browser.i18n?.getMessage("ui_b791d0fcafae")||"Réglage indisponible. Rechargez cette page.");});
$("notify").addEventListener("change",async()=>{
 const enabled=$("notify").checked;$("notify").disabled=true;$("notification-status").textContent="";
 try {
  const r=await browser.runtime.sendMessage({kind:"setDownloadNotifications",enabled});
  if(!r?.ok)throw new Error(r?.error||(browser.i18n?.getMessage("ui_c1486275c837")||"Modification impossible."));
  notificationsEnabled=enabled;
 }catch(e){$("notify").checked=notificationsEnabled;$("notification-status").textContent=e.message;}
 finally{$("notify").disabled=false;}
});

async function refreshNotificationStatus(){
 const [r,s]=await Promise.all([call({command:"notificationStatus"}),browser.storage.local.get(["downloadNotifications","notificationError","lastNotificationCheck"])]);
 if(!r?.ok)return;
 $("notification-status").textContent=s.downloadNotifications===true?(!r.authorized||!r.banners?(browser.i18n?.getMessage("ui_cdc531eeb77d")||"Autorisez les bannières de UGREEN NAS Download dans Réglages Système → Notifications."):s.notificationError||(s.lastNotificationCheck?(browser.i18n?.getMessage("ui_aa5f51ab7162")||"Dernière vérification des téléchargements : ")+new Date(s.lastNotificationCheck).toLocaleTimeString(browser.i18n?.getUILanguage()||"fr"):(browser.i18n?.getMessage("ui_bc8a610a15ef")||"La surveillance reprend automatiquement."))):"";
}
refreshNotificationStatus().catch(()=>{});
$("test-notification").addEventListener("click",async()=>{
 $("test-notification").disabled=true;
 try{const r=await call({command:"testNotification"});$("notification-status").textContent=r?.ok?(browser.i18n?.getMessage("ui_d880fbbb21d5")||"Notification de test envoyée. Si elle reste invisible, vérifiez le mode Concentration et les réglages de notifications."):r?.error||(browser.i18n?.getMessage("ui_c30bdfb591a9")||"Test indisponible.");}catch{$("notification-status").textContent=(browser.i18n?.getMessage("ui_c30bdfb591a9")||"Test indisponible.");}finally{$("test-notification").disabled=false;}
});
browser.storage.onChanged.addListener(changes=>{if(changes.notificationError||changes.lastNotificationCheck)refreshNotificationStatus().catch(()=>{});});

$("discover").addEventListener("click",async()=>{
 $("discover").disabled=true;$("discovery-results").replaceChildren();$("discovery-status").textContent=(browser.i18n?.getMessage("ui_69a73fdd87c7")||"Recherche des NAS…");
 try{
  const r=await call({command:"discover"});
  if(!r?.ok)throw new Error(r?.error||(browser.i18n?.getMessage("ui_9e5c694d62ed")||"Recherche indisponible."));
  if(!Array.isArray(r.devices))throw new Error((browser.i18n?.getMessage("ui_5bb39ffa1a2f")||"Réponse de recherche inattendue."));
  $("discovery-status").textContent=r.devices.length?(browser.i18n?.getMessage("ui_5fd0980a2907")||"Choisissez votre NAS, puis vérifiez son certificat."):(browser.i18n?.getMessage("ui_3ea1e67e5d0e")||"Aucun NAS trouvé. Vérifiez votre réseau ou saisissez son adresse manuellement.");
  for(const device of r.devices){
   const item=document.createElement("li"),button=document.createElement("button");button.type="button";button.textContent=device.name+" · "+device.model+" — "+device.address;
   button.addEventListener("click",()=>{reset();$("address").value=device.address;$("discovery-status").textContent=(browser.i18n?.getMessage("ui_71a547ac7d47")||"Adresse renseignée. Vérifiez le certificat avant de vous connecter.");$("address").focus();});
   item.append(button);$("discovery-results").append(item);
  }
 }catch(e){$("discovery-status").textContent=e.message+(browser.i18n?.getMessage("ui_4fd15b694321")||" Vous pouvez saisir l’adresse manuellement.");}
 finally{$("discover").disabled=false;}
});
