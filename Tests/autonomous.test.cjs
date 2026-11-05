const {test}=require('node:test');const assert=require('node:assert/strict');const fs=require('node:fs');const vm=require('node:vm');const path=require('node:path');
function setup(initial={},reply=()=>({ok:true,message:'accepté'})){
 let handler,installed,startup,alarmHandler,contextHandler;const calls=[],scripts=[],alarms=[],menus=[],feedback=[],state={enabled:true,...initial};
 const browser={scripting:{executeScript:async args=>scripts.push(args)},contextMenus:{removeAll:async()=>{},create:item=>{menus.push(item);return item.id;},onClicked:{addListener:f=>contextHandler=f}},browserAction:{setBadgeText:async()=>{}},tabs:{sendMessage:async(...args)=>feedback.push(args)},runtime:{getURL:p=>'safari-web-extension://TEST/'+p,onMessage:{addListener:f=>handler=f},onInstalled:{addListener:f=>installed=f},onStartup:{addListener:f=>startup=f},openOptionsPage:async()=>calls.push('options'),sendNativeMessage:async(app,payload)=>{calls.push(payload);return reply(payload);}},storage:{local:{get:async()=>state,set:async value=>Object.assign(state,value)}},alarms:{get:async()=>undefined,create:(...a)=>alarms.push(a),clear:async name=>alarms.push(['clear',name]),onAlarm:{addListener:f=>alarmHandler=f}}};
 vm.runInNewContext(fs.readFileSync(path.join(__dirname,'../Extension/background.js'),'utf8'),{browser,URL});
 return{handler,calls,scripts,state,alarms,menus,feedback,context:(info,tab={id:1})=>contextHandler(info,tab),installed:args=>installed(args),startup:()=>startup(),alarm:args=>alarmHandler(args)};
}
test('une page ne peut pas configurer le compte NAS',async()=>{const h=setup();await h.handler({kind:'nativeOptions',payload:{command:'configure',password:'FAKE'}},{url:'https://example.com',tab:{id:1}});assert.equal(h.calls.length,0);});
test('le popup ne peut pas configurer le compte à la place des options',async()=>{const h=setup();await h.handler({kind:'nativeOptions',payload:{command:'configure'}},{url:'safari-web-extension://TEST/popup.html'});assert.equal(h.calls.length,0);});
test('les options peuvent transmettre la configuration au module natif',async()=>{const h=setup();await h.handler({kind:'nativeOptions',payload:{command:'configure',password:'FAKE'}},{url:'safari-web-extension://TEST/options.html'});assert.equal(h.calls[0].command,'configure');});
test('commandes non prévues refusées',async()=>{const h=setup();await h.handler({kind:'nativeOptions',payload:{command:'shell'}},{url:'safari-web-extension://TEST/options.html'});assert.equal(h.calls.length,0);});
test('envoi natif sans aucune requête vers un onglet NAS',async()=>{const h=setup();const r=await h.handler({kind:'sendLink',link:'magnet:?xt=urn:btih:'+'a'.repeat(40)},{url:'https://example.com',tab:{id:1}});assert.equal(r.ok,true);assert.equal(h.calls[0].command,'send');});
test('aucun envoi depuis un expéditeur non autorisé',async()=>{const h=setup();await h.handler({kind:'sendLink',link:'https://example.com/a.torrent'},{url:'file:///tmp/test'});assert.equal(h.calls.length,0);});
test('taille des messages bornée avant passage au natif',async()=>{const h=setup();await h.handler({kind:'sendLink',link:'x'.repeat(65537)},{url:'https://example.com',tab:{id:1}});assert.equal(h.calls.length,0);});
test('un torrent en mémoire est transmis depuis une page autorisée',async()=>{const h=setup();const r=await h.handler({kind:'sendTorrent',data:'ZDQ6aW5mb2RlZQ=='},{url:'https://tracker.example/details/123',tab:{id:1}});assert.equal(r.ok,true);assert.equal(h.calls[0].command,'sendTorrent');});
test('les options ne peuvent pas injecter un torrent comme une page',async()=>{const h=setup();await h.handler({kind:'sendTorrent',data:'abc'},{url:'safari-web-extension://TEST/options.html'});assert.equal(h.calls.length,0);});
test('les gros torrents sont refusés avant le module natif',async()=>{const h=setup();const r=await h.handler({kind:'sendTorrent',data:'x'.repeat(699053)},{url:'https://tracker.example/',tab:{id:1}});assert.equal(r.ok,false);assert.equal(h.calls.length,0);});
function pageBridge(){const listeners={},doc={};let original=0;const messages=[],revoked=[],timers=[];class Anchor{click(){original++;}}class TestURL extends URL{}TestURL.revokeObjectURL=u=>revoked.push(u);const window={addEventListener:(k,f)=>listeners[k]=f,postMessage:m=>messages.push(m)};const document={addEventListener:(k,f)=>doc[k]=f};const location={origin:'https://tracker.example',href:'https://tracker.example/details'};vm.runInNewContext(fs.readFileSync(path.join(__dirname,'../Extension/page-bridge.js'),'utf8'),{window,document,location,URL:TestURL,HTMLAnchorElement:Anchor,Date,Reflect,Set,setTimeout:f=>timers.push(f)});return{messages,revoked,timers,Anchor,URL:TestURL,original:()=>original,enable:()=>listeners.message({source:window,origin:location.origin,data:{ugreenBridge:'state',enabled:true}}),gesture:()=>doc.click({isTrusted:true})};}
test('un téléchargement blob torrent est capturé après un clic utilisateur',()=>{const h=pageBridge();h.enable();h.gesture();const a=new h.Anchor();a.href='blob:https://tracker.example/id';a.download='sample.torrent';a.click();assert.equal(h.original(),0);assert.equal(h.messages.find(m=>m.ugreenBridge==='torrentDownload').url,a.href);h.URL.revokeObjectURL(a.href);assert.equal(h.revoked.length,0);h.timers[0]();assert.equal(h.revoked.length,1);});
test('interception désactivée : le téléchargement original est conservé',()=>{const h=pageBridge();h.gesture();const a=new h.Anchor();a.href='blob:https://tracker.example/id';a.download='sample.torrent';a.click();assert.equal(h.original(),1);assert.equal(h.messages.filter(m=>m.ugreenBridge==='torrentDownload').length,0);});
test('un script sans geste utilisateur ne déclenche pas le NAS',()=>{const h=pageBridge();h.enable();const a=new h.Anchor();a.href='blob:https://tracker.example/id';a.download='sample.torrent';a.click();assert.equal(h.original(),1);assert.equal(h.messages.filter(m=>m.ugreenBridge==='torrentDownload').length,0);});
test('un téléchargement ordinaire reste sur le Mac',()=>{const h=pageBridge();h.enable();h.gesture();const a=new h.Anchor();a.href='blob:https://tracker.example/id';a.download='sample.pdf';a.click();assert.equal(h.original(),1);});
test('une page web ne peut pas lire les téléchargements du NAS',async()=>{const h=setup();await h.handler({kind:'listDownloads'},{url:'https://tracker.example/',tab:{id:1}});assert.equal(h.calls.length,0);});
test('seul le menu peut lire les téléchargements',async()=>{const h=setup();await h.handler({kind:'listDownloads'},{url:'safari-web-extension://TEST/options.html'});assert.equal(h.calls.length,0);await h.handler({kind:'listDownloads'},{url:'safari-web-extension://TEST/popup.html'});assert.equal(h.calls[0].command,'downloads');});

test('une page ne peut pas autoriser les notifications',async()=>{const h=setup();await h.handler({kind:'enableNotifications'},{url:'https://example.com',tab:{id:1}});assert.equal(h.calls.length,0);});

test('activation des notifications réservée aux paramètres',async()=>{const h=setup();await h.handler({kind:'setDownloadNotifications',enabled:true},{url:'safari-web-extension://TEST/popup.html'});assert.equal(h.calls.length,0);});
test('interrupteur activé : permission et suivi, choix enregistré',async()=>{const h=setup();const r=await h.handler({kind:'setDownloadNotifications',enabled:true},{url:'safari-web-extension://TEST/options.html'});assert.equal(r.ok,true);assert.equal(h.state.downloadNotifications,true);assert.equal(h.calls[0].command,'enableNotifications');assert.equal(h.calls[1].command,'monitorDownloads');assert.ok(h.alarms.some(a=>a[0]==='nas-downloads'));});
test('interrupteur désactivé : arrêt du suivi sans appel NAS ni notification',async()=>{const h=setup();h.state.downloadNotifications=true;const r=await h.handler({kind:'setDownloadNotifications',enabled:false},{url:'safari-web-extension://TEST/options.html'});assert.equal(r.ok,true);assert.equal(h.state.downloadNotifications,false);assert.equal(h.calls.length,1);assert.equal(h.calls[0].command,'disableNotifications');assert.ok(h.alarms.some(a=>a[0]==='clear'&&a[1]==='nas-downloads'));});

test('mise à jour : rétablissement des alertes sans ouvrir les options',async()=>{const h=setup({downloadNotifications:true});await h.installed({reason:'update'});assert.ok(h.alarms.some(a=>a[0]==='nas-downloads'));assert.equal(h.calls.includes('options'),false);});
test('redémarrage Safari : surveillance restaurée si activée',async()=>{const h=setup({downloadNotifications:true});await h.startup();assert.ok(h.alarms.some(a=>a[0]==='nas-downloads'));});
test('redémarrage Safari : choix désactivé respecté',async()=>{const h=setup({downloadNotifications:false});await h.startup();assert.ok(h.alarms.some(a=>a[0]==='clear'&&a[1]==='nas-downloads'));assert.ok(!h.alarms.some(a=>a[0]==='nas-downloads'));});
test('erreur de notification affichable dans les paramètres',async()=>{const h=setup({downloadNotifications:true},()=>({ok:false,error:'Bannières désactivées'}));await h.alarm({name:'nas-downloads'});assert.equal(h.state.notificationError,'Bannières désactivées');});
test('une page ne peut pas envoyer une notification de test',async()=>{const h=setup();await h.handler({kind:'nativeOptions',payload:{command:'testNotification'}},{url:'https://example.com',tab:{id:1}});assert.equal(h.calls.length,0);});
test('les options peuvent lire l’autorisation macOS des alertes',async()=>{const h=setup();await h.handler({kind:'nativeOptions',payload:{command:'notificationStatus'}},{url:'safari-web-extension://TEST/options.html'});assert.equal(h.calls[0].command,'notificationStatus');});

test('la surveillance périodique mémorise une vérification réussie',async()=>{const h=setup({downloadNotifications:true});await h.alarm({name:'nas-downloads'});assert.equal(typeof h.state.lastNotificationCheck,'number');assert.equal(h.state.notificationError,'');});

test('le menu propose fichiers, images, vidéos et audio',async()=>{const h=setup();await new Promise(setImmediate);assert.equal(h.menus[0].title,'Télécharger sur le NAS');assert.deepEqual(Array.from(h.menus[0].contexts),['link','image','video','audio']);});
test('clic droit DMG : envoi au NAS même si interception automatique désactivée',async()=>{const h=setup({enabled:false});await h.context({menuItemId:'download-on-nas',linkUrl:'https://example.com/app.dmg'});assert.equal(h.calls[0].command,'sendDownload');assert.equal(h.calls[0].link,'https://example.com/app.dmg');assert.equal(h.state.lastContextResult.ok,true);});
test('clic droit image dans un lien : privilégie le fichier image',async()=>{const h=setup();await h.context({menuItemId:'download-on-nas',mediaType:'image',srcUrl:'https://example.com/photo.jpg',linkUrl:'https://example.com/gallery'});assert.equal(h.calls[0].link,'https://example.com/photo.jpg');});
test('clic droit vidéo directe : préserve le lien et ses paramètres',async()=>{const h=setup();await h.context({menuItemId:'download-on-nas',mediaType:'video',srcUrl:'https://example.com/film.mp4?key=test'});assert.equal(h.calls[0].link,'https://example.com/film.mp4?key=test');});
test('blob vidéo : erreur claire, aucun envoi et aucun téléchargement local',async()=>{const h=setup();await h.context({menuItemId:'download-on-nas',mediaType:'video',srcUrl:'blob:https://example.com/id'});assert.equal(h.calls.length,0);assert.equal(h.state.lastContextResult.ok,false);assert.match(h.state.lastContextResult.text,/généré/);});
test('une page web ne peut pas envoyer un fichier ordinaire via un message forgé',async()=>{const h=setup();await h.handler({kind:'sendDownload',link:'https://example.com/app.exe'},{url:'https://example.com',tab:{id:1}});assert.equal(h.calls.length,0);});
test('les liens avec identifiants intégrés sont refusés avant envoi',async()=>{const h=setup();await h.context({menuItemId:'download-on-nas',linkUrl:'https://user:password@example.com/app.zip'});assert.equal(h.calls.length,0);assert.equal(h.state.lastContextResult.ok,false);});
test('le lien manuel du popup accepte le parcours générique',async()=>{const h=setup();await h.handler({kind:'sendLink',link:'https://example.com/app.exe'},{url:'safari-web-extension://TEST/popup.html'});assert.equal(h.calls[0].command,'sendDownload');});
test('requêtes natives sérialisées : un relevé ne bloque pas un téléchargement',async()=>{let release;const gate=new Promise(r=>release=r);const h=setup({},async p=>{if(p.command==='downloads')await gate;return{ok:true};});const poll=h.handler({kind:'listDownloads'},{url:'safari-web-extension://TEST/popup.html'});await new Promise(setImmediate);const send=h.context({menuItemId:'download-on-nas',linkUrl:'https://example.com/app.zip'});await new Promise(setImmediate);assert.equal(h.calls.length,1);release();await Promise.all([poll,send]);assert.equal(h.calls[1].command,'sendDownload');});

test('le module de boutons complexes est injecté dans le cadre demandeur',async()=>{
 const h=setup();await h.handler({kind:'installBridge'},{url:'https://example.com/ad',tab:{id:12},frameId:7});
 assert.deepEqual(JSON.parse(JSON.stringify(h.scripts[0].target)),{tabId:12,frameIds:[7]});
});
test('indicateur : liens directs disponibles même sans confirmation des boutons complexes',async()=>{
 const source=fs.readFileSync(path.join(__dirname,'../Extension/popup.js'),'utf8');
 const fn=source.slice(source.indexOf('async function updatePageIndicator()'),source.indexOf('\nupdatePageIndicator();'));
 const indicator={dataset:{}};let options;
 const context={$:()=>indicator,browser:{tabs:{query:async()=>[{id:12,url:'https://example.com/news'}],sendMessage:async(id,msg,opts)=>{options=opts;return{enabled:true,bridgeAck:false};}}}};
 vm.createContext(context);vm.runInContext(fn,context);await context.updatePageIndicator();
 assert.equal(indicator.textContent,'Extension active · liens directs');assert.equal(indicator.dataset.state,'ready');assert.equal(options.frameId,0);
 context.browser.tabs.sendMessage=async()=>{throw Error('permission')};await context.updatePageIndicator();assert.equal(indicator.dataset.state,'unavailable');
});

test('Safari sans mediaType : le fichier sélectionné prime sur la page liée',async()=>{const h=setup();await h.context({menuItemId:'download-on-nas',srcUrl:'https://example.com/photo.jpg',linkUrl:'https://example.com/article'});assert.equal(h.calls[0].link,'https://example.com/photo.jpg');});
test('média sans source : ne télécharge pas la page liée à sa place',async()=>{const h=setup();await h.context({menuItemId:'download-on-nas',mediaType:'video',linkUrl:'https://example.com/article',pageUrl:'https://example.com/article'});assert.equal(h.calls.length,0);assert.equal(h.state.lastContextResult.ok,false);});

test('correction des noms indépendante des notifications',async()=>{const h=setup({downloadNotifications:false});await h.startup();assert.ok(h.alarms.some(a=>a[0]==='nas-filenames'));await h.alarm({name:'nas-filenames'});assert.equal(h.calls[0].command,'labelDownloads');});

test('désactivation refusée : le choix et la surveillance restent actifs',async()=>{
 const h=setup({downloadNotifications:true},()=>({ok:false,error:'opération occupée'}));
 const r=await h.handler({kind:'setDownloadNotifications',enabled:false},{url:'safari-web-extension://TEST/options.html'});
 assert.equal(r.ok,false);assert.equal(h.state.downloadNotifications,true);
 assert.ok(!h.alarms.some(a=>a[0]==='clear'&&a[1]==='nas-downloads'));
});
test('désactivation sans réponse : aucune fausse confirmation',async()=>{
 const h=setup({downloadNotifications:true},()=>undefined);
 const r=await h.handler({kind:'setDownloadNotifications',enabled:false},{url:'safari-web-extension://TEST/options.html'});
 assert.equal(r.ok,false);assert.equal(h.state.downloadNotifications,true);
});

test('NAS lent : les alarmes identiques ne s’accumulent pas',async()=>{
 let release;const h=setup({},()=>new Promise(resolve=>{release=resolve;}));
 const first=h.alarm({name:'nas-filenames'});
 await new Promise(resolve=>setImmediate(resolve));
 await h.alarm({name:'nas-filenames'});
 assert.equal(h.calls.length,1);release({ok:true});await first;
 await h.alarm({name:'unrelated'});assert.equal(h.calls.length,1);
});

test('site torrent bloqué : expiration et nouvel essai possibles',async()=>{
 const clicks=[],alerts=[],timers=[];let fetches=0;
 class Anchor{}const anchor=new Anchor();anchor.href='https://tracker.example/test.torrent';anchor.download='';anchor.textContent='torrent';
 const window={postMessage:()=>{},addEventListener:()=>{},alert:text=>alerts.push(text)};
 const browser={runtime:{sendMessage:async()=>({ok:true}),onMessage:{addListener:()=>{}}},storage:{local:{get:async()=>({enabled:true})},onChanged:{addListener:()=>{}}}};
 const document={addEventListener:(kind,fn)=>{if(kind==='click')clicks.push(fn);}};
 const location={origin:'https://tracker.example',href:'https://tracker.example/page',pathname:'/page'};
 const fetch=(_url,opts)=>{fetches++;return new Promise((_,reject)=>opts.signal.addEventListener('abort',()=>reject(Object.assign(new Error('aborted'),{name:'AbortError'}))));};
 vm.runInNewContext(fs.readFileSync(path.join(__dirname,'../Extension/content.js'),'utf8'),{browser,window,document,location,fetch,URL,HTMLAnchorElement:Anchor,AbortController,Date,setTimeout:(fn,ms)=>{timers.push({fn,ms});return timers.length;},clearTimeout:()=>{}});
 await new Promise(resolve=>setImmediate(resolve));
 function click(){for(const fn of clicks)fn({isTrusted:true,button:0,composedPath:()=>[anchor],preventDefault:()=>{},stopImmediatePropagation:()=>{}});}
 click();assert.equal(fetches,1);assert.equal(timers[0].ms,20000);timers[0].fn();
 await new Promise(resolve=>setImmediate(resolve));
 assert.match(alerts[0],/20 secondes/);click();assert.equal(fetches,2);timers[1].fn();
 await new Promise(resolve=>setImmediate(resolve));
});
