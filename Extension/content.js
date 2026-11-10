(() => {
  let enabled=false,busy=false,recentGesture=0,bridgeStatus=(browser.i18n?.getMessage("ui_1347b8f0a0e4")||"Initialisation…"),bridgeAck=false;
  const tellBridge=()=>window.postMessage({ugreenBridge:"state",enabled},location.origin);
  const bridgeReady=browser.runtime.sendMessage({kind:"installBridge"}).then(r=>{bridgeStatus=r?.ok?(browser.i18n?.getMessage("ui_1052b279ffe6")||"Script chargé"):r?.error||(browser.i18n?.getMessage("ui_62611dbedb70")||"Injection refusée");tellBridge();}).catch(()=>{bridgeStatus=(browser.i18n?.getMessage("ui_f963644d9839")||"Module Safari indisponible");});
  browser.storage.local.get("enabled").then(s=>{enabled=s.enabled===true;bridgeReady.then(tellBridge);});
  browser.storage.onChanged.addListener((changes,area)=>{if(area==="local"&&changes.enabled){enabled=changes.enabled.newValue===true;tellBridge();}});
  document.addEventListener("click",e=>{if(e.isTrusted)recentGesture=Date.now();},true);
  function parsed(raw){try{const u=new URL(raw,location.href);if(u.protocol==="magnet:"||["http:","https:"].includes(u.protocol))return u;if(u.protocol==="blob:"&&u.origin===location.origin)return u;}catch{}return null;}
  async function transfer(url,file){
    if(busy||!enabled)return;
    busy=true;
    const controller=new AbortController();let fetchTimeout;
    try{
      let result;
      if(!file)result=await browser.runtime.sendMessage({kind:"sendLink",link:url.href});
      else {
        if(url.protocol!=="blob:"&&url.origin!==location.origin)throw new Error((browser.i18n?.getMessage("ui_98c28c423cc5")||"Le torrent protégé doit être accessible depuis ce site. Aucun cookie n’est transmis à un autre site."));
        fetchTimeout=setTimeout(()=>controller.abort(),20000);
        const response=await fetch(url.href,{credentials:"include",redirect:"error",cache:"no-store",signal:controller.signal});
        if(!response.ok)throw new Error((browser.i18n?.getMessage("ui_c847f62838fd")||"Le site refuse l’accès au torrent. Vérifiez votre connexion au site."));
        if(Number(response.headers.get("content-length"))>524288)throw new Error((browser.i18n?.getMessage("ui_cd3568f6a76b")||"Torrent trop volumineux (limite 512 Ko)."));
        const reader=response.body.getReader(),chunks=[];let size=0;
        try{for(;;){const {done,value}=await reader.read();if(done)break;size+=value.length;if(size>524288){await reader.cancel();throw new Error((browser.i18n?.getMessage("ui_cd3568f6a76b")||"Torrent trop volumineux (limite 512 Ko)."));}chunks.push(value);}}finally{reader.releaseLock();}
        clearTimeout(fetchTimeout);
        const bytes=new Uint8Array(size);let offset=0;for(const chunk of chunks){bytes.set(chunk,offset);offset+=chunk.length;}
        if(bytes[0]!==100||bytes[bytes.length-1]!==101)throw new Error((browser.i18n?.getMessage("ui_df84ce2fd25c")||"Le site n’a pas renvoyé un fichier torrent valide."));
        let binary="";for(let i=0;i<bytes.length;i+=8192)binary+=String.fromCharCode(...bytes.subarray(i,i+8192));
        result=await browser.runtime.sendMessage({kind:"sendTorrent",data:btoa(binary)});
      }
      window.alert(result?.ok?result.message:result?.error||(browser.i18n?.getMessage("ui_e69bcfcdd24c")||"Aucune confirmation. Vérifiez les tâches du NAS avant de réessayer."));
    }catch(error){window.alert(error?.name==="AbortError"?(browser.i18n?.getMessage("ui_82e766fc3000")||"Le site n’a pas fourni le torrent dans les 20 secondes. Vous pouvez réessayer."):error?.message||(browser.i18n?.getMessage("ui_4b5f254ca06c")||"Envoi non confirmé. Vérifiez les tâches du NAS avant de réessayer."));}
    finally{clearTimeout(fetchTimeout);busy=false;}
  }
  document.addEventListener("click",event=>{
    if(!enabled||!event.isTrusted||event.button!==0||event.metaKey||event.ctrlKey||event.altKey||event.shiftKey)return;
    const anchor=event.composedPath().find(n=>n instanceof HTMLAnchorElement);if(!anchor)return;
    const url=parsed(anchor.href);if(!url)return;
    const named=/\.torrent$/i.test(anchor.download||"") || (/\.torrent\b/i.test(anchor.textContent||"") && url.origin===location.origin && url.pathname!==location.pathname);
    if(url.protocol!=="magnet:"&&!named&&!/\.torrent$/i.test(url.pathname))return;
    event.preventDefault();event.stopImmediatePropagation();
    transfer(url,url.protocol!=="magnet:" && (url.protocol==="blob:"||url.origin===location.origin));
  },true);
  function contextNotice(result){
    document.getElementById("ugreen-download-notice")?.remove();
    const box=document.createElement("div");box.id="ugreen-download-notice";box.setAttribute("role",result?.ok?"status":"alert");
    box.textContent=(result?.ok?"UGREEN NAS Download : ":"UGREEN NAS Download — ")+(result?.message||result?.error||(browser.i18n?.getMessage("ui_a413ef4f1131")||"Envoi non confirmé."));
    box.style.cssText="position:fixed!important;right:24px!important;bottom:24px!important;z-index:2147483647!important;max-width:380px!important;padding:16px 20px!important;border-radius:14px!important;background:#242528!important;color:#fff!important;box-shadow:0 8px 32px #0005!important;font:13px/1.5 -apple-system,BlinkMacSystemFont,sans-serif!important;white-space:normal!important;overflow-wrap:anywhere!important;";
    (document.body||document.documentElement).append(box);setTimeout(()=>box.remove(),8000);
  }
  browser.runtime.onMessage.addListener(message=>{if(message?.kind==="contextDownloadResult"){contextNotice(message.result);return Promise.resolve({ok:true});}if(message?.kind==="interceptionStatus"){tellBridge();return Promise.resolve({enabled,bridgeStatus,bridgeAck});}});
  window.addEventListener("message",event=>{
    if(event.source===window&&event.origin===location.origin&&event.data?.ugreenBridge==="bridgeLoaded"){tellBridge();return;}
    if(event.source===window&&event.origin===location.origin&&event.data?.ugreenBridge==="ready"){bridgeAck=true;return;}
    if(event.source!==window||event.origin!==location.origin||event.data?.ugreenBridge!=="torrentDownload"||!enabled||Date.now()-recentGesture>30000)return;
    const url=parsed(event.data.url);if(!url)return;
    if(url.protocol!=="magnet:"&&!/\.torrent$/i.test(event.data.name||"")&&!/\.torrent$/i.test(url.pathname))return;
    transfer(url,url.protocol!=="magnet:"&&(url.protocol==="blob:"||url.origin===location.origin));
  });
})();
