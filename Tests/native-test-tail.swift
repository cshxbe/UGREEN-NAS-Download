import AppKit
@main struct NativeTests {
 @MainActor static func main() {
  let app=NSApplication.shared
  app.setActivationPolicy(.prohibited)
  Task { @MainActor in
   do {try await run();exit(0)} catch {print("FAIL native transport test: \(type(of:error))");exit(1)}
  }
  app.run()
 }
 @MainActor static func run() async throws {
  var count=0
  func check(_ value:Bool,_ name:String){precondition(value,name);count+=1;print("PASS "+name)}

  check(mimeExtension("image/jpeg; charset=binary")=="jpg","MIME JPEG reconnu")
  check(mimeExtension("application/pdf")=="pdf","MIME PDF reconnu")
  check(mimeExtension("application/octet-stream")==nil,"type générique non deviné")
  check(magicExtension(Data([255,216,255,224]))=="jpg","signature JPEG reconnue")
  check(magicExtension(Data("%PDF-1.7".utf8))=="pdf","signature PDF reconnue")
  check(magicExtension(Data([80,75,3,4]))=="zip","signature ZIP reconnue")
  check(magicExtension(Data("not a format".utf8))==nil,"contenu inconnu non deviné")
  func ftyp(_ brand:String)->Data{Data([0,0,0,24]+Array("ftyp".utf8)+Array(brand.utf8)+[0,0,0,0])}
  check(magicExtension(ftyp("M4A "))=="m4a","audio M4A non renommé en vidéo MP4")
  check(magicExtension(ftyp("M4B "))=="m4b","livre audio M4B reconnu")
  check(magicExtension(ftyp("3gp6"))=="3gp","conteneur 3GP reconnu")
  check(magicExtension(ftyp("????"))==nil,"conteneur ftyp inconnu non deviné")
  check(magicExtension(ftyp("mif1"))==nil,"marque générique HEIF non assimilée à HEIC")
  let audioHeaders=HTTPURLResponse(url:URL(string:"https://example.com/audio")!,statusCode:200,httpVersion:nil,headerFields:["Content-Type":"audio/mp4"])!
  check(inferredLabel(headers:audioHeaders,bytes:ftyp("isom")).ext=="m4a","audio MIME conservé malgré une signature ISO générique")
  check(labelledName("audio.m4a",FileLabel(ext:"mp4"))=="audio.m4a","extension audio spécifique conservée")
  for state in [1e300,-1e300,Double.infinity,Double.nan,2.5] {
   let rows=downloadRows([["id":"untrusted","task_status":state]])
   check(rows.first?["state"] as? Int==0,"état numérique invalide sans arrêt du processus")
  }

  check(dispositionName("attachment; filename*=UTF-8''rapport%20%C3%A9t%C3%A9.pdf")=="rapport été.pdf","nom RFC5987 décodé")
  check(dispositionName("attachment; filename=\"archive.zip\"")=="archive.zip","nom serveur conservé")
  let response=HTTPURLResponse(url:URL(string:"https://example.com/download?signature=keep")!,statusCode:206,httpVersion:"HTTP/1.1",headerFields:["Content-Type":"application/octet-stream"])!
  check(inferredLabel(headers:response,bytes:Data([255,216,255])).ext=="jpg","signature identifie un type MIME générique")
  check(labelledName("photo",FileLabel(ext:"jpg"))=="photo.jpg","extension manquante ajoutée")
  check(labelledName("photo.2",FileLabel(ext:"jpg"))=="photo.2.jpg","suffixe de collision conservé")
  check(labelledName("photo.jpeg",FileLabel(ext:"jpg"))=="photo.jpeg","extension équivalente conservée")
  check(labelledName("photo.php",FileLabel(ext:"jpg"))=="photo.jpg","extension de page remplacée par le type réel")
  check(labelPath(directory:"/home/user/downloads",name:"../other")==nil,"renommage hors du dossier refusé")
  check(labelPath(directory:"/home/user/downloads",name:"photo.jpg")=="/home/user/downloads/photo.jpg","chemin de fichier contrôlé")
  check(labelledName("download",FileLabel(ext:"pdf",name:"Rapport.pdf"))=="Rapport.pdf","nom complet annoncé par le serveur appliqué")
  check(labelledName("table.csv",FileLabel(ext:"txt"))=="table.csv","format texte plus précis conservé")
  check(labelledName("document.docx",FileLabel(ext:"zip"))=="document.docx","conteneur Office non réduit à ZIP")
  let labelJob=LabelJob(sourceHash:sourceDigest("https://example.com/file?token=keep"),directory:"/home/user/downloads",previousIDs:["old"],label:FileLabel(ext:"jpg"),created:Date(),taskID:nil)
  let newRow:[String:Any]=["id":"new","link_type":1,"download_url":"https://example.com/file?token=keep","save_dir":"/home/user/downloads/"]
  check(matchesLabelJob(newRow,labelJob),"seul le nouveau fichier de cet envoi est éligible")
  for (key,value) in [("id","old"),("download_url","https://example.com/file?token=other"),("save_dir","/home/user/elsewhere")] {var row=newRow;row[key]=value;check(!matchesLabelJob(row,labelJob),"historique, autre lien ou autre dossier exclu")}
  for kind in [6,7] {var row=newRow;row["link_type"]=kind;check(!matchesLabelJob(row,labelJob),"torrent et magnet jamais renommés par le correcteur HTTP")}
  let signed=URL(string:"https://example.com/download?id=12&signature=keep%2Bexact")!
  check(fileProbeRequest(signed).url==signed,"paramètres et signature du lien inchangés")
  check(fileProbeRequest(signed).httpMethod=="HEAD","lien à paramètres inspecté sans seconde lecture du corps")
  check(fileProbeRequest(URL(string:"https://example.com/photo")!).value(forHTTPHeaderField:"Range")=="bytes=0-8191","lecture de signature limitée à 8 Kio")
  let longName=String(repeating:"é",count:180)+".pdf"
  check(safeFilename(longName)?.hasSuffix(".pdf")==true,"nom long réduit sans perdre son extension")
  let longImage=labelledName(String(repeating:"é",count:120),FileLabel(ext:"jpg"))!
  check(longImage.hasSuffix(".jpg") && longImage.utf8.count<=220,"extension réelle préservée pour un nom Unicode long")
  let discoveryFixture=Data(#"{"code":200,"data":{"deviceMatchs":[{"name":"NAS","model":"DXP2800","ipv4":"192.168.1.100","ext":{"httpsPort":9443,"netInfo":{"ipv4":["192.168.1.100","10.0.0.2","8.8.8.8","127.0.0.1","evil.example"]}}}]}}"#.utf8)
  let discovered=try discoveredNAS(discoveryFixture)
  check(discovered.count==2,"découverte limitée aux adresses privées et sans doublons")
  check(discovered.first?["address"]=="https://192.168.1.100:9443","port HTTPS annoncé conservé")
  check(try discoveredNAS(Data(#"{"code":200,"data":{"deviceMatchs":[]}}"#.utf8)).isEmpty,"aucun NAS trouvé est un résultat valide")
  for bad in [#"{"code":500,"data":{"deviceMatchs":[]}}"#,"<html>error</html>"] {do{_ = try discoveredNAS(Data(bad.utf8));preconditionFailure("découverte invalide acceptée")}catch{count+=1}}
  check(try endpoint("https://nas.example:9443").host=="nas.example","adresse HTTPS")
  for bad in ["http://nas","https://user:pw@nas","https://nas/path","https://nas/?token=x"] {do{_ = try endpoint(bad);preconditionFailure("adresse acceptée")}catch{count+=1}}
  check(try link("https://example.org/a.torrent?key=test")=="https://example.org/a.torrent?key=test","paramètres conservés")
  check(try link("magnet:?xt=urn:btih:"+String(repeating:"a",count:40)).hasPrefix("magnet:"),"magnet")
  for bad in ["file:///tmp/a.torrent","https://u:p@host/a.torrent","magnet:?xt=invalid","https://host/a.torrent\n"] {do{_ = try link(bad);preconditionFailure("lien accepté")}catch{count+=1}}
  for suffix in ["dmg","exe","zip","jpg","png","mp4","pdf"] {
   let url="https://example.org/file."+suffix+"?signature=test"
   check(try downloadLink(url)==url,"URL générique acceptée : "+suffix)
  }
  check(try downloadLink("https://example.org/download?id=12")=="https://example.org/download?id=12","URL sans extension acceptée")
  for bad in ["file:///tmp/app.dmg","javascript:alert(1)","blob:https://example.org/id","data:text/plain,test","https://u:p@example.org/a.zip","https://example.org/app.exe\r\n"] {do{_ = try downloadLink(bad);preconditionFailure("lien générique dangereux accepté")}catch{count+=1}}
  check(try downloadLink("MAGNET:?xt=urn:btih:"+String(repeating:"a",count:40)).hasPrefix("MAGNET:"),"schéma magnet insensible à la casse")
  check(try link("HTTPS://example.org/file.torrent").hasPrefix("HTTPS:"),"schéma HTTPS insensible à la casse")
  let attrs:[String:Any]=[kSecAttrKeyType as String:kSecAttrKeyTypeRSA,kSecAttrKeySizeInBits as String:2048]
  let privateKey=SecKeyCreateRandomKey(attrs as CFDictionary,nil)!
  let publicKey=SecKeyCopyPublicKey(privateKey)!
  let der=SecKeyCopyExternalRepresentation(publicKey,nil)! as Data
  let parsed=try rsaKey(der.base64EncodedString())
  let encrypted=try encryptPassword("test éphémère",key:parsed)
  let decrypted=SecKeyCreateDecryptedData(privateKey,.rsaEncryptionPKCS1,Data(base64Encoded:encrypted)! as CFData,nil)! as Data
  check(String(data:decrypted,encoding:.utf8)=="test éphémère","RSA PKCS1 aller-retour")
  let probe=Transport(host:"127.0.0.1",pin:nil)
  let url=URL(string:"https://127.0.0.1:18443/")!
  _ = try await probe.perform(URLRequest(url:url))
  check(probe.observed?.count==64,"empreinte du certificat de test")
  let pinned=Transport(host:"127.0.0.1",pin:probe.observed!)
  let (_,http)=try await pinned.perform(URLRequest(url:url))
  check(http.statusCode==200,"certificat approuvé accepté")
  do {_ = try await Transport(host:"127.0.0.1",pin:String(repeating:"0",count:64)).perform(URLRequest(url:url));preconditionFailure("mauvais certificat accepté")}catch{count+=1;print("PASS certificat différent refusé")}
  do {_ = try await pinned.perform(URLRequest(url:URL(string:"https://127.0.0.1:18443/redirect")!));preconditionFailure("redirection acceptée")}catch{count+=1;print("PASS redirection refusée")}
  let fixture=Data("d4:infod4:name4:testee".utf8)
  check(try torrentData(fixture.base64EncodedString())==fixture,"torrent transmis sans modification")
  for invalid in ["<html>login</html>","d4:info4:teste","d4:infodeeTRAILING"] {
   do {_ = try torrentData(Data(invalid.utf8).base64EncodedString());preconditionFailure("faux torrent accepté")}catch{count+=1}
  }
  var post=URLRequest(url:url);post.httpMethod="POST";post.httpBody=Data("{\"test\":\"value\"}".utf8);post.setValue("application/json",forHTTPHeaderField:"Content-Type")
  let (body,headers)=try await pinned.perform(post)
  check((try JSONSerialization.jsonObject(with:body) as? [String:String])?["test"]=="value","corps POST transmis et JSON relu")
  check(headers.value(forHTTPHeaderField:"x-rsa-token")=="test-public-key","en-tête RSA accessible")
  check(try downloadBatch(["result":NSNull(),"total":0]).isEmpty,"liste nulle sans téléchargement acceptée")
  check(try downloadBatch(["total":"0"]).isEmpty,"liste absente et total nul acceptés")
  check(try downloadBatch(["result":[]]).isEmpty,"tableau vide accepté")
  do {_ = try downloadBatch(["result":NSNull(),"total":2]);preconditionFailure("liste tronquée acceptée")}catch{count+=1}
  check(!downloadPageFinished([:],batchCount:50,receivedCount:50),"page pleine sans total : poursuite de la liste")
  check(!downloadPageFinished(["total":"101"],batchCount:50,receivedCount:100),"total texte respecté au-delà de 50 tâches")
  check(downloadPageFinished(["total":100],batchCount:50,receivedCount:100),"dernière page pleine reconnue")
  check(downloadPageFinished([:],batchCount:0,receivedCount:100),"fin sans total reconnue par page vide")
  check(downloadTotal(["total":1e300])==nil,"total hors limites rejeté sans plantage")
  check(downloadEvent(previous:nil,current:3)==nil,"pas d'alerte historique au premier relevé")
  check(downloadEvent(previous:3,current:3)==nil,"pas de notification répétée")
  check(downloadEvent(previous:2,current:3)=="Téléchargement terminé","fin détectée")
  check(downloadEvent(previous:2,current:4)=="Téléchargement stoppé","arrêt détecté")
  check(downloadEvent(previous:2,current:5)=="Téléchargement en erreur","erreur détectée")
  check(downloadEvent(previous:4,current:2)==nil,"reprise sans fausse alerte")
  check(nasSaveDirectory("/home/utilisateur/Telechargements/")=="/home/utilisateur/Telechargements","slash final retiré pour éviter un nom de fichier racine")
  check(nasSaveDirectory("/home/utilisateur/Telechargements")=="/home/utilisateur/Telechargements","dossier sans slash final conservé")
  check(nasSaveDirectory("/")=="/","racine conservée et jamais transformée en chemin vide")
  let selected=try resourceImport(["save_dir":"/destination/","link_type":6,"resource_path":"/tmp/torrent","download_url":"opaque","files":[["name":"/","type":true,"path":"/","files":[["name":"Exemple.2026.mkv","path":"/Exemple.2026.mkv","size":10,"type":false]]]]])!
  check(selected["task_name"] as? String=="Exemple.2026.mkv","nom complet et extension utilisés malgré une racine slash")
  check((selected["resource_files"] as? [[String:Any]])?.count==1,"seuls les fichiers sont confirmés, sans dossier racine artificiel")
  check(selected["force"] as? Bool==false,"aucun remplacement forcé d’une tâche existante")
  check(selected["resource_path"] as? String=="/tmp/torrent","chemin de ressource du NAS conservé")
  let multi=try resourceImport(["files":[["name":"Album","type":true,"files":[["name":"1.flac","path":"/Album/1.flac"],["name":"2.flac","path":"/Album/2.flac"]]]]])!
  check(multi["task_name"] as? String=="Album" && (multi["resource_files"] as? [[String:Any]])?.count==2,"torrent multifichier conserve son dossier et tous ses fichiers")
  check(try resourceImport(["files":[]])==nil,"magnet sans métadonnées identifié séparément")
  let fast:[[String:Any]]=[["id":"new","state":3,"name":"rapide.zip"],["id":"old","state":3,"name":"ancien.pdf"]]
  check(newDownloadEvents(previous:nil,current:fast,knownCompleted:nil).isEmpty,"aucune alerte historique au premier relevé des fichiers terminés")
  let fastEvents=newDownloadEvents(previous:[],current:fast,knownCompleted:["old"])
  check(fastEvents.count==1 && fastEvents[0]["name"] as? String=="rapide.zip","petit fichier terminé entre deux relevés détecté sans annoncer l’historique")
  check(newDownloadEvents(previous:fast,current:fast,knownCompleted:["new","old"]).isEmpty,"aucune notification répétée des fichiers terminés")
  check(newDownloadEvents(previous:[["id":"new","state":2]],current:[fast[0]],knownCompleted:[]).count==1,"fin normale émise une seule fois")
  check(newDownloadEvents(previous:[],current:[["id":"error","state":5,"name":"échec.dmg"]],knownCompleted:[]).count==1,"erreur rapide détectée même sans relevé de l’état actif")
  let tasks=downloadRows([
   ["id":1,"link_type":6,"task_status":2,"download_file_name":"Test A","total_size":"1000","downloaded_size":"250","download_speed":"125"],
   ["id":2,"link_type":7,"task_status":4,"download_file_name":"Test B","plan":"80.5","total_size":2000,"downloaded_size":1610,"download_speed":0],
   ["id":3,"link_type":6,"task_status":6,"download_file_name":"/","task_name":"Métadonnées","total_size":0],
   ["id":4,"link_type":6,"task_status":3,"download_file_name":"Terminé"],
   ["id":5,"link_type":1,"task_status":2,"download_file_name":"HTTP"]])
  check(tasks.count==4,"torrents et fichiers HTTP conservés, tâches terminées exclues")
  check(tasks[0]["progress"] as? Double==25,"progression calculée sur les octets reçus")
  check(tasks[0]["speed"] as? Double==125,"vitesse du NAS convertie depuis une chaîne")
  check(tasks[1]["state"] as? Int==4 && tasks[1]["progress"] as? Double==80.5,"torrent en pause et progression NAS conservés")
  check(tasks[2]["progress"] is NSNull && tasks[2]["name"] as? String=="Métadonnées","taille inconnue et nom de secours")
  check(tasks.allSatisfy{$0["download_url"]==nil && $0["token"]==nil},"aucune URL privée ni jeton dans la liste du menu")
  var binaryPost=URLRequest(url:URL(string:"https://127.0.0.1:18443/binary")!);binaryPost.httpMethod="POST";binaryPost.httpBody=Data([0,255,128,1,13,10,100,101]);binaryPost.setValue("application/octet-stream",forHTTPHeaderField:"Content-Type")
  let (binaryResponse,_)=try await pinned.perform(binaryPost)
  let echoed=try JSONSerialization.jsonObject(with:binaryResponse) as! [String:String]
  check(echoed["base64"]==binaryPost.httpBody!.base64EncodedString(),"octets binaires POST transmis sans altération")
  print("Native tests: \(count) passed; aucun compte ni secret réel utilisé")
 }
}
