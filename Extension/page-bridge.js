(() => {
  if(window.__ugreenTorrentBridge)return;
  window.__ugreenTorrentBridge=true;
  let enabled=false,recentGesture=0;
  document.addEventListener("click",event=>{if(event.isTrusted)recentGesture=Date.now();},true);
  window.addEventListener("message",event=>{if(event.source===window&&event.origin===location.origin&&event.data?.ugreenBridge==="state"){enabled=event.data.enabled===true;window.postMessage({ugreenBridge:"ready"},location.origin);}});
  const original=HTMLAnchorElement.prototype.click;
  HTMLAnchorElement.prototype.click=function(...args){
    let url;try{url=new URL(this.href,location.href);}catch{return Reflect.apply(original,this,args);}
    if(enabled&&Date.now()-recentGesture<30000&&(url.protocol==="magnet:"||/\.torrent$/i.test(this.download||"")||/\.torrent$/i.test(url.pathname))){
      const allowed=url.protocol==="magnet:"||["https:","http:"].includes(url.protocol)||(url.protocol==="blob:"&&url.origin===location.origin);
      if(allowed){
        window.postMessage({ugreenBridge:"torrentDownload",url:url.href,name:this.download||""},location.origin);
        // Many sites revoke a blob immediately after click(). Hold this specific blob
        // briefly so the isolated extension can read it; no data is written to disk.
        if(url.protocol==="blob:")held.add(url.href);
        return;
      }
    }
    return Reflect.apply(original,this,args);
  };
  const held=new Set(),revoke=URL.revokeObjectURL.bind(URL);
  URL.revokeObjectURL=function(url){if(held.delete(String(url)))setTimeout(()=>revoke(url),30000);else revoke(url);};
  window.postMessage({ugreenBridge:"bridgeLoaded"},location.origin);
})();
