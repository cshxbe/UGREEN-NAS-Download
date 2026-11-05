const $=id=>document.getElementById(id);
const call=payload=>browser.runtime.sendMessage({kind:"nativeOptions",payload});
let candidate=null;
function reset(){candidate=null;$("trust").checked=false;$("trust").disabled=true;$("save").disabled=true;$("fingerprint").textContent="";}
$("address").addEventListener("input",reset);
call({command:"status"}).then(r=>{if(r?.configured){for(const k of ["address","username","saveDir"])$(k).value=r[k];$("password").placeholder="Laisser vide pour conserver le mot de passe actuel";$("status").textContent="Compte configuré. Session et identifiants conservés dans le Trousseau.";}}).catch(()=>$("status").textContent="Ouvrez l’application Mac puis réessayez.");
$("probe").addEventListener("click",async()=>{reset();$("probe").disabled=true;$("status").textContent="Lecture du certificat, sans transmission d’identifiants…";try{const r=await call({command:"probe",address:$("address").value.trim()});if(!r?.ok)throw new Error(r?.error||"NAS inaccessible.");candidate=r.candidate;$("fingerprint").textContent="SHA-256 : "+r.fingerprint.match(/.{1,2}/g).join(":");$("trust").disabled=false;$("status").textContent="Vérifiez l’empreinte, puis confirmez le NAS.";}catch(e){$("status").textContent=e.message;}finally{$("probe").disabled=false;}});
$("trust").addEventListener("change",()=>$("save").disabled=!$("trust").checked);
$("config").addEventListener("submit",async e=>{e.preventDefault();if(!candidate||!$("trust").checked)return;$("save").disabled=true;$("status").textContent="Test de connexion au NAS…";try{const r=await call({command:"configure",candidate,address:$("address").value.trim(),username:$("username").value.trim(),password:$("password").value,otp:$("otp").value.trim(),trustDevice:$("trustDevice").checked,saveDir:$("saveDir").value.trim()});$("password").value="";$("otp").value="";reset();$("status").textContent=r?.message||r?.error||"Connexion non confirmée.";}catch{$("password").value="";$("otp").value="";reset();$("status").textContent="Connexion non confirmée. Vérifiez le NAS et recommencez.";}});
$("forget").addEventListener("click",async()=>{if(!confirm("Supprimer les identifiants et la session du Trousseau pour ce profil Safari ?"))return;const r=await call({command:"forget"});if(r?.ok){$("password").value="";$("otp").value="";reset();$("status").textContent="Compte oublié.";}else $("status").textContent=r?.error||"Suppression impossible.";});

let notificationsEnabled=false;
browser.storage.local.get("downloadNotifications").then(s=>{notificationsEnabled=s.downloadNotifications===true;$("notify").checked=notificationsEnabled;$("notify").disabled=false;}).catch(()=>{$("notification-status").textContent="Réglage indisponible. Rechargez cette page.";});
$("notify").addEventListener("change",async()=>{
 const enabled=$("notify").checked;$("notify").disabled=true;$("notification-status").textContent="";
 try {
  const r=await browser.runtime.sendMessage({kind:"setDownloadNotifications",enabled});
  if(!r?.ok)throw new Error(r?.error||"Modification impossible.");
  notificationsEnabled=enabled;
 }catch(e){$("notify").checked=notificationsEnabled;$("notification-status").textContent=e.message;}
 finally{$("notify").disabled=false;}
});

async function refreshNotificationStatus(){
 const [r,s]=await Promise.all([call({command:"notificationStatus"}),browser.storage.local.get(["downloadNotifications","notificationError","lastNotificationCheck"])]);
 if(!r?.ok)return;
 $("notification-status").textContent=s.downloadNotifications===true?(!r.authorized||!r.banners?"Autorisez les bannières de UGREEN NAS Download dans Réglages Système → Notifications.":s.notificationError||(s.lastNotificationCheck?"Dernière vérification des téléchargements : "+new Date(s.lastNotificationCheck).toLocaleTimeString("fr-FR"):"La surveillance reprend automatiquement.")):"";
}
refreshNotificationStatus().catch(()=>{});
$("test-notification").addEventListener("click",async()=>{
 $("test-notification").disabled=true;
 try{const r=await call({command:"testNotification"});$("notification-status").textContent=r?.ok?"Notification de test envoyée. Si elle reste invisible, vérifiez le mode Concentration et les réglages de notifications.":r?.error||"Test indisponible.";}catch{$("notification-status").textContent="Test indisponible.";}finally{$("test-notification").disabled=false;}
});
browser.storage.onChanged.addListener(changes=>{if(changes.notificationError||changes.lastNotificationCheck)refreshNotificationStatus().catch(()=>{});});

$("discover").addEventListener("click",async()=>{
 $("discover").disabled=true;$("discovery-results").replaceChildren();$("discovery-status").textContent="Recherche des NAS…";
 try{
  const r=await call({command:"discover"});
  if(!r?.ok)throw new Error(r?.error||"Recherche indisponible.");
  if(!Array.isArray(r.devices))throw new Error("Réponse de recherche inattendue.");
  $("discovery-status").textContent=r.devices.length?"Choisissez votre NAS, puis vérifiez son certificat.":"Aucun NAS trouvé. Vérifiez votre réseau ou saisissez son adresse manuellement.";
  for(const device of r.devices){
   const item=document.createElement("li"),button=document.createElement("button");button.type="button";button.textContent=device.name+" · "+device.model+" — "+device.address;
   button.addEventListener("click",()=>{reset();$("address").value=device.address;$("discovery-status").textContent="Adresse renseignée. Vérifiez le certificat avant de vous connecter.";$("address").focus();});
   item.append(button);$("discovery-results").append(item);
  }
 }catch(e){$("discovery-status").textContent=e.message+" Vous pouvez saisir l’adresse manuellement.";}
 finally{$("discover").disabled=false;}
});
