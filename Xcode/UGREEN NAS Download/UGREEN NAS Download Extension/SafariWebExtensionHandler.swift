import Foundation
import SafariServices
import Security
import CryptoKit
import WebKit
import UserNotifications
import OSLog
import UniformTypeIdentifiers

private enum DownloadNotifications {
    private static let logger=Logger(subsystem:"com.example.UGREENNASDownload",category:"Notifications")
    static func status() async -> [String:Any] {
        let settings=await UNUserNotificationCenter.current().notificationSettings()
        let authorized=settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
        return ["ok":true,"authorized":authorized,"banners":settings.alertSetting == .enabled,"temporary":settings.alertStyle == .banner]
    }
    static func send(id:String,title:String,body:String) async throws {
        let settings=await status()
        guard settings["authorized"] as? Bool == true,settings["banners"] as? Bool == true else {
            logger.error("Notification blocked by system settings")
            throw fail(L("ui_cdc531eeb77d", "Autorisez les bannières de UGREEN NAS Download dans Réglages Système → Notifications."))
        }
        let content=UNMutableNotificationContent();content.title=title;content.body=body;content.sound = .default
        do {
            try await UNUserNotificationCenter.current().add(UNNotificationRequest(identifier:id,content:content,trigger:nil))
            logger.info("Notification submitted successfully")
        } catch {
            logger.error("Notification submission failed, code: \((error as NSError).code,privacy:.public)")
            throw fail(L("ui_b43b586485e3", "macOS n’a pas accepté la notification. Vérifiez les réglages de notifications de l’application."))
        }
    }
}
private enum ClientError: Error { case message(String); case expired }
private func fail(_ message: String) -> ClientError { .message(message) }
private func endpoint(_ raw: String) throws -> URL {
    guard let c = URLComponents(string: raw.trimmingCharacters(in: .whitespacesAndNewlines)), c.scheme == "https", let host = c.host, !host.isEmpty, c.user == nil, c.password == nil, c.query == nil, c.fragment == nil, c.path.isEmpty || c.path == "/", let url = c.url else { throw fail(L("ui_f5addc7b5c24", "Utilisez une adresse HTTPS complète, avec son port, sans chemin ni identifiants.")) }
    return url
}
private struct Account: Codable {
    var address: String; var username: String; var password: String; var fingerprint: String
    var saveDir: String; var clientID: String; var token: String?; var authType: String?
}
private enum Vault {
    // Public edition uses its own Keychain namespace.
    static func query(_ profile: String) -> [String: Any] { [kSecClass as String:kSecClassGenericPassword,kSecAttrService as String:"UGREEN NAS Download",kSecAttrAccount as String:profile] }
    static func read(_ profile: String) throws -> Account? {
        var q = query(profile); q[kSecReturnData as String] = true; q[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?; let status = SecItemCopyMatching(q as CFDictionary, &item)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = item as? Data else { throw fail(L("ui_9209362478e0", "Accès au Trousseau refusé ou verrouillé.")) }
        return try JSONDecoder().decode(Account.self, from:data)
    }
    static func write(_ account: Account, _ profile: String) throws {
        let data = try JSONEncoder().encode(account); let q = query(profile)
        let status = SecItemUpdate(q as CFDictionary,[kSecValueData as String:data] as CFDictionary)
        if status == errSecItemNotFound {
            var add = q; add[kSecValueData as String] = data; add[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            guard SecItemAdd(add as CFDictionary,nil) == errSecSuccess else { throw fail(L("ui_eb583918b61e", "Impossible d’enregistrer les identifiants dans le Trousseau.")) }
        } else if status != errSecSuccess { throw fail(L("ui_079197b78282", "Impossible de mettre à jour le Trousseau.")) }
    }
    static func remove(_ profile: String) throws {
        let s = SecItemDelete(query(profile) as CFDictionary)
        guard s == errSecSuccess || s == errSecItemNotFound else { throw fail(L("ui_b77404083cf4", "Suppression du compte impossible.")) }
    }
}
// A probe sends no password/token. Subsequent connections must match the approved certificate.
private final class Transport {
    let host:String; let pin:String?; var observed:String?
    init(host:String,pin:String?) { self.host=host;self.pin=pin }
    func perform(_ request:URLRequest) async throws -> (Data,HTTPURLResponse) {
        let result = try await WebRequest.run(request,host:host,pin:pin)
        observed=result.2
        return (result.0,result.1)
    }
}
// An isolated web engine performs API requests only. No NAS page or remote scripts are loaded.
@MainActor private final class WebRequest:NSObject,WKNavigationDelegate {
    private var view:WKWebView?
    private var continuation:CheckedContinuation<(Data,HTTPURLResponse,String?),Error>?
    private var timeout:Task<Void,Never>?
    private let request:URLRequest; private let host:String; private let pin:String?
    private var observed:String?; private var response:HTTPURLResponse?
    private init(_ request:URLRequest,host:String,pin:String?) {self.request=request;self.host=host;self.pin=pin}
    static func run(_ request:URLRequest,host:String,pin:String?) async throws -> (Data,HTTPURLResponse,String?) {
        let operation=WebRequest(request,host:host,pin:pin)
        return try await withCheckedThrowingContinuation { continuation in
            operation.continuation=continuation
            let configuration=WKWebViewConfiguration()
            configuration.websiteDataStore = .nonPersistent()
            configuration.defaultWebpagePreferences.allowsContentJavaScript=false
            let view=WKWebView(frame:.zero,configuration:configuration)
            operation.view=view;view.navigationDelegate=operation
            // The timeout retains the operation until its single completion.
            operation.timeout=Task { @MainActor in
                try? await Task.sleep(nanoseconds:35_000_000_000)
                if !Task.isCancelled {operation.finish(.failure(URLError(.timedOut)))}
            }
            view.load(request)
        }
    }
    private func finish(_ result:Result<(Data,HTTPURLResponse,String?),Error>) {
        guard let continuation=continuation else {return}
        self.continuation=nil;timeout?.cancel();timeout=nil
        view?.navigationDelegate=nil;view?.stopLoading();view=nil
        continuation.resume(with:result)
    }
    func webView(_ webView:WKWebView,didReceive challenge:URLAuthenticationChallenge,completionHandler:@escaping(URLSession.AuthChallengeDisposition,URLCredential?)->Void) {
        guard challenge.protectionSpace.authenticationMethod==NSURLAuthenticationMethodServerTrust,
              challenge.protectionSpace.host==host,let trust=challenge.protectionSpace.serverTrust,
              let certificates=SecTrustCopyCertificateChain(trust) as? [SecCertificate],let certificate=certificates.first else {
            completionHandler(.cancelAuthenticationChallenge,nil);return
        }
        let hash=SHA256.hash(data:SecCertificateCopyData(certificate) as Data).map{String(format:"%02x",$0)}.joined()
        observed=hash
        guard pin==nil || pin==hash else {completionHandler(.cancelAuthenticationChallenge,nil);return}
        completionHandler(.useCredential,URLCredential(trust:trust))
    }
    func webView(_ webView:WKWebView,decidePolicyFor navigationAction:WKNavigationAction,decisionHandler:@escaping(WKNavigationActionPolicy)->Void) {
        guard navigationAction.request.url==request.url else {decisionHandler(.cancel);finish(.failure(fail(L("ui_b52ac257e9d5", "Redirection NAS refusée."))));return}
        decisionHandler(.allow)
    }
    func webView(_ webView:WKWebView,didReceiveServerRedirectForProvisionalNavigation navigation:WKNavigation!) {
        finish(.failure(fail(L("ui_b52ac257e9d5", "Redirection NAS refusée."))))
    }
    func webView(_ webView:WKWebView,decidePolicyFor navigationResponse:WKNavigationResponse,decisionHandler:@escaping(WKNavigationResponsePolicy)->Void) {
        guard let http=navigationResponse.response as? HTTPURLResponse,http.url==request.url,
              !(300..<400).contains(http.statusCode),http.expectedContentLength<4*1024*1024,
              ["application/json","text/plain"].contains(http.mimeType ?? "") else {
            decisionHandler(.cancel);finish(.failure(fail(L("ui_f51ec28c3af6", "Réponse API NAS invalide ou redirection refusée."))));return
        }
        response=http;decisionHandler(.allow)
    }
    func webView(_ webView:WKWebView,didFinish navigation:WKNavigation!) {
        guard let response=response else {finish(.failure(fail(L("ui_ff1507c53259", "Réponse NAS absente."))));return}
        // The private content world reads JSON text; page JavaScript remains disabled.
        webView.evaluateJavaScript("document.body.textContent",in:nil,in:.defaultClient) { result in
            switch result {
            case .success(let value):
                guard let text=value as? String,let data=text.data(using:.utf8),data.count<4*1024*1024 else {self.finish(.failure(fail(L("ui_d6ce26cae65c", "Réponse NAS trop volumineuse."))));return}
                self.finish(.success((data,response,self.observed)))
            case .failure: self.finish(.failure(fail(L("ui_ae437aff49ba", "Lecture de la réponse NAS impossible."))))
            }
        }
    }
    func webView(_ webView:WKWebView,didFailProvisionalNavigation navigation:WKNavigation!,withError error:Error) {finish(.failure(error))}
    func webView(_ webView:WKWebView,didFail navigation:WKNavigation!,withError error:Error) {finish(.failure(error))}
    func webViewWebContentProcessDidTerminate(_ webView:WKWebView) {finish(.failure(fail(L("ui_a974c8e3f389", "Connexion NAS interrompue."))))}
}
private func rsaKey(_ raw: String) throws -> SecKey {
    var text=raw.trimmingCharacters(in:.whitespacesAndNewlines)
    if let decoded=Data(base64Encoded:text), let pem=String(data:decoded,encoding:.utf8),pem.contains("BEGIN") {text=pem}
    let content=text.components(separatedBy:.newlines).filter{!$0.contains("-----")}.joined()
    guard let data=Data(base64Encoded:content,options:.ignoreUnknownCharacters) else {throw fail(L("ui_b044999d35ab", "Clé de connexion NAS invalide."))}
    let attributes:[String:Any]=[kSecAttrKeyType as String:kSecAttrKeyTypeRSA,kSecAttrKeyClass as String:kSecAttrKeyClassPublic]
    if let key=SecKeyCreateWithData(data as CFData,attributes as CFDictionary,nil) {return key}
    // Unwrap SubjectPublicKeyInfo into PKCS#1, without assuming fixed DER lengths.
    func field(_ d:Data,_ index:inout Int) throws -> (UInt8,Data) {
        let bytes=Array(d);guard index+2<=bytes.count else {throw fail(L("ui_428d624126cb", "DER invalide."))}
        let tag=bytes[index];index+=1;let first=Int(bytes[index]);index+=1;var length=first
        if first&128 != 0 {let count=first&127;guard count>0 && count<=4 && index+count<=bytes.count else {throw fail(L("ui_428d624126cb", "DER invalide."))};length=0;for _ in 0..<count {length=(length<<8)|Int(bytes[index]);index+=1}}
        guard length>=0 && length<=bytes.count-index else {throw fail(L("ui_428d624126cb", "DER invalide."))}
        let result=Data(bytes[index..<index+length]);index+=length;return(tag,result)
    }
    var i=0;let outer=try field(data,&i);guard outer.0==0x30 else {throw fail(L("ui_7b80438ec983", "Clé RSA invalide."))}
    i=0;_ = try field(outer.1,&i);let bits=try field(outer.1,&i)
    guard bits.0==3,bits.1.first==0,let key=SecKeyCreateWithData(bits.1.dropFirst() as CFData,attributes as CFDictionary,nil) else {throw fail(L("ui_dbb5f4df5427", "Clé RSA non prise en charge."))}
    return key
}
private func encryptPassword(_ password:String,key:SecKey) throws -> String {
    guard let data=SecKeyCreateEncryptedData(key,.rsaEncryptionPKCS1,Data(password.utf8) as CFData,nil) else {throw fail(L("ui_e7bd42ba90b0", "Chiffrement du mot de passe impossible."))}
    return (data as Data).base64EncodedString()
}
private func link(_ raw:String) throws -> String {
    guard raw.utf8.count<=65536,!raw.contains(where:{$0.isNewline || $0=="\0"}), let u=URLComponents(string:raw),u.user==nil,u.password==nil else {throw fail(L("ui_6658df9c38ab", "Lien invalide."))}
    if u.scheme?.lowercased()=="magnet" {
        let values=u.queryItems?.filter{$0.name=="xt"}.compactMap{$0.value} ?? []
        let pattern="^urn:(btih:([a-f0-9]{40}|[a-z2-7]{32})|btmh:1220[a-f0-9]{64})$"
        guard values.contains(where:{$0.range(of:pattern,options:[.regularExpression,.caseInsensitive]) != nil}) else {throw fail(L("ui_f3cdccb5402b", "Identifiant magnet invalide."))}
    } else {guard ["https","http"].contains(u.scheme?.lowercased() ?? ""),u.host != nil,u.path.lowercased().hasSuffix(".torrent") else {throw fail(L("ui_cb5b339795b7", "URL torrent invalide."))}}
    return raw
}
// Context-menu/manual downloads accept any remote file type, independently of the torrent interceptor.
private func downloadLink(_ raw:String) throws -> String {
    if raw.lowercased().hasPrefix("magnet:") {return try link(raw)}
    guard raw.utf8.count<=65536,!raw.contains(where:{$0.isNewline || $0=="\0"}),
          let c=URLComponents(string:raw),["http","https"].contains(c.scheme?.lowercased() ?? ""),
          let host=c.host,!host.isEmpty,c.user==nil,c.password==nil,c.url != nil else {
        throw fail(L("ui_cd3dac3e4a2a", "Utilisez un lien HTTP ou HTTPS direct vers le fichier, sans identifiants intégrés."))
    }
    return raw
}
private func torrentData(_ raw:String) throws -> Data {
    guard raw.utf8.count<=699052,let data=Data(base64Encoded:raw),data.count<=524288,!data.isEmpty else {throw fail(L("ui_3716aaf78bec", "Torrent invalide ou supérieur à 512 Ko."))}
    let bytes=Array(data);var index=0;var nodes=0;var hasInfo=false
    func parse(_ depth:Int,_ root:Bool=false) throws {
        nodes+=1;guard depth<=32,nodes<=100000,index<bytes.count else {throw fail(L("ui_912d2e061225", "Structure torrent invalide."))}
        let marker=bytes[index]
        if marker>=48 && marker<=57 {
            var length=0;var digits=0
            while index<bytes.count,bytes[index]>=48,bytes[index]<=57 {digits+=1;guard digits<=7 else {throw fail(L("ui_3326f8e02c15", "Longueur torrent invalide."))};length=length*10+Int(bytes[index]-48);index+=1}
            guard index<bytes.count,bytes[index]==58,length<=bytes.count-index-1 else {throw fail(L("ui_a74be4e6d377", "Chaîne torrent invalide."))};index+=1+length
        } else if marker==105 {
            index+=1;if index<bytes.count,bytes[index]==45 {index+=1}
            let start=index;while index<bytes.count,bytes[index]>=48,bytes[index]<=57 {index+=1}
            guard index>start,index<bytes.count,bytes[index]==101 else {throw fail(L("ui_8402366c958d", "Entier torrent invalide."))};index+=1
        } else if marker==108 || marker==100 {
            index+=1
            while index<bytes.count,bytes[index] != 101 {
                if marker==100 {
                    guard bytes[index]>=48,bytes[index]<=57 else {throw fail(L("ui_2d34af66a278", "Clé torrent invalide."))}
                    let start=index;try parse(depth+1)
                    let isInfo=root && Array(bytes[start..<index])==Array("4:info".utf8)
                    if isInfo {guard index<bytes.count,bytes[index]==100,!hasInfo else {throw fail(L("ui_82813a88c223", "Dictionnaire info invalide."))};hasInfo=true}
                    try parse(depth+1)
                } else {try parse(depth+1)}
            }
            guard index<bytes.count else {throw fail(L("ui_b88378cc7549", "Torrent incomplet."))};index+=1
        } else {throw fail(L("ui_4024b2fc5907", "Contenu reçu non torrent."))}
    }
    guard bytes.first==100 else {throw fail(L("ui_75f70ed3140a", "Le contenu reçu n’est pas un torrent."))}
    try parse(0,true)
    guard index==bytes.count,hasInfo else {throw fail(L("ui_4a8e63360f63", "Métadonnées torrent absentes ou invalides."))}
    return data
}
private func nasSaveDirectory(_ path:String) -> String {
    // UGOS derives the displayed root incorrectly when save_dir ends in a slash.
    let normalized=path.replacingOccurrences(of:"/+$",with:"",options:.regularExpression)
    return normalized.isEmpty ? "/" : normalized
}
// Match the NAS resource picker: select leaf files and explicitly name the task.
// Keep the torrent bytes and resource paths unchanged; renaming metadata would alter its hash.
private func resourceImport(_ parsed:[String:Any]) throws -> [String:Any]? {
    guard let roots=parsed["files"] as? [[String:Any]],!roots.isEmpty else {return nil}
    var leaves:[[String:Any]]=[]
    func walk(_ nodes:[[String:Any]],depth:Int) throws {
        guard depth<=32,leaves.count<=100000 else {throw fail(L("ui_90c67be91210", "Arborescence du torrent trop volumineuse."))}
        for node in nodes {
            let children=node["files"] as? [[String:Any]] ?? []
            let folder=(node["type"] as? NSNumber)?.boolValue == true || !children.isEmpty
            if folder {try walk(children,depth:depth+1)}
            else {var leaf=node;leaf.removeValue(forKey:"files");leaf["type"]=false;leaf["download"]=true;leaves.append(leaf)}
        }
    }
    try walk(roots,depth:0)
    guard !leaves.isEmpty else {throw fail(L("ui_8eb203ba941d", "Le NAS n’a identifié aucun fichier à télécharger."))}
    let first=leaves[0]
    var name=leaves.count==1 ? first["name"] as? String : roots.first?["name"] as? String
    if name == nil || name=="/" || name?.isEmpty==true {name=parsed["task_name"] as? String}
    guard let raw=name,!raw.isEmpty,raw != "/" else {throw fail(L("ui_137e68b05223", "Le NAS n’a pas identifié le nom du torrent. Aucune tâche n’a été confirmée."))}
    // Use the NAS's filename restrictions while preserving the extension.
    let cleaned=raw.components(separatedBy:CharacterSet(charactersIn:"\\/:*?\"<>|\r\n\0")).joined(separator:" ").trimmingCharacters(in:.whitespacesAndNewlines)
    guard !cleaned.isEmpty,cleaned.count<=255,!cleaned.hasPrefix("."),!cleaned.hasPrefix(":") else {throw fail(L("ui_5ebaf4042fab", "Nom de tâche refusé par le NAS."))}
    var result:[String:Any]=["task_name":cleaned,"resource_files":leaves,"force":false]
    for key in ["save_dir","link_type","download_url","resource_path"] {if let value=parsed[key] {result[key]=value}}
    return result
}
private func downloadBatch(_ data:[String:Any]) throws -> [[String:Any]] {
    if let list=data["result"] as? [[String:Any]] {return list}
    if data["result"] == nil || data["result"] is NSNull {
        let count=(data["total"] as? NSNumber)?.intValue ?? Int(data["total"] as? String ?? "")
        if count == nil || count == 0 {return []}
    }
    throw fail(L("ui_409c39d465ec", "Liste des téléchargements reçue dans un format inattendu."))
}
// A full page without a total is not evidence that the list ends here.
private func downloadTotal(_ data:[String:Any])->Int? {
    if let value=data["total"] as? NSNumber,let total=Int(exactly:value.doubleValue),total>=0{return total}
    if let value=data["total"] as? String,let total=Int(value),total>=0{return total}
    return nil
}
private func downloadPageFinished(_ data:[String:Any],batchCount:Int,receivedCount:Int)->Bool {
    batchCount<50 || downloadTotal(data).map({receivedCount >= $0})==true
}
private func downloadEvent(previous:Int?,current:Int) -> String? {
    guard let previous=previous,previous != current else {return nil}
    switch current {
    case 3:return L("ui_19356d0fa0b7", "Téléchargement terminé")
    case 4:return L("ui_f01c5b082925", "Téléchargement stoppé")
    case 5:return L("ui_8a9821880139", "Téléchargement en erreur")
    default:return nil
    }
}
// Completed-file polling also catches files that start and finish between two active-list polls.
private func newDownloadEvents(previous:[[String:Any]]?,current:[[String:Any]],knownCompleted:Set<String>?) -> [[String:Any]] {
    guard let previous=previous else {return []}
    var before:[String:Int]=[:],latest:[String:[String:Any]]=[:]
    for task in previous {if let id=task["id"] as? String,let state=task["state"] as? Int {before[id]=state}}
    for task in current {if let id=task["id"] as? String,!id.isEmpty {latest[id]=task}}
    return latest.compactMap {id,task in
        guard let state=task["state"] as? Int else {return nil}
        let title:String?
        if let old=before[id] {title=downloadEvent(previous:old,current:state)}
        else if state==3 {title=knownCompleted.map{!$0.contains(id) ? L("ui_19356d0fa0b7", "Téléchargement terminé") : nil} ?? nil}
        else {title=downloadEvent(previous:0,current:state)}
        guard let title=title else {return nil}
        return ["title":title,"name":task["name"] ?? L("ui_38858cd588e0", "Téléchargement")]
    }
}
private func downloadRows(_ rows:[[String:Any]]) -> [[String:Any]] {
    func number(_ raw:Any?) -> Double? {
        let n=(raw as? NSNumber)?.doubleValue ?? Double(raw as? String ?? "")
        guard let n=n,n.isFinite else {return nil};return n
    }
    return rows.compactMap { row in
        let state=number(row["task_status"]).flatMap{Int(exactly:$0)} ?? 0
        guard state != 3 else {return nil}
        let size=max(0,number(row["total_size"]) ?? 0),done=max(0,number(row["downloaded_size"]) ?? 0)
        let plan=number(row["plan"]) ?? (size>0 ? done/size*100 : nil)
        let names=[row["download_file_name"],row["task_name"],row["name"]].compactMap{$0 as? String}.filter{!$0.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty && $0 != "/"}
        return ["id":String(describing:row["id"] ?? ""),"name":String((names.first ?? "Téléchargement sans nom").prefix(1024)),"state":state,"progress":plan.map{min(100,max(0,$0))} as Any? ?? NSNull(),"downloaded":done,"size":size,"speed":max(0,number(row["download_speed"]) ?? 0)]
    }
}
// Discovery is untrusted metadata only: no credentials, cookies or certificate approval.
private final class DiscoveryRedirectPolicy:NSObject,URLSessionTaskDelegate,@unchecked Sendable {
    func urlSession(_ session:URLSession,task:URLSessionTask,willPerformHTTPRedirection response:HTTPURLResponse,newRequest request:URLRequest,completionHandler:@escaping(URLRequest?)->Void){completionHandler(nil)}
}
private func discoveredNAS(_ data:Data) throws -> [[String:String]] {
    guard data.count<=1_048_576,let root=try JSONSerialization.jsonObject(with:data) as? [String:Any],root["code"] as? Int == 200,let body=root["data"] as? [String:Any],let rows=body["deviceMatchs"] as? [[String:Any]] else {throw fail(L("ui_5dffb3ac450b", "Réponse du service de recherche UGREEN inattendue."))}
    var results:[[String:String]]=[];var seen=Set<String>()
    for row in rows.prefix(100) {
        guard let ext=row["ext"] as? [String:Any],let port=ext["httpsPort"] as? Int,(1...65535).contains(port) else {continue}
        let net=ext["netInfo"] as? [String:Any]
        let ips=([row["ipv4"] as? String].compactMap{$0})+(net?["ipv4"] as? [String] ?? [])
        for ip in ips.prefix(16) {
            let parts=ip.split(separator:".",omittingEmptySubsequences:false)
            guard parts.count==4,parts.allSatisfy({!$0.isEmpty && $0.allSatisfy({$0.isASCII && $0.isNumber}) && Int($0).map{(0...255).contains($0)} == true}) else {continue}
            let octets=parts.compactMap{Int($0)}
            guard octets[0]==10 || (octets[0]==172 && (16...31).contains(octets[1])) || (octets[0]==192 && octets[1]==168) else {continue}
            let address="https://\(ip):\(port)"
            if seen.insert(address).inserted {results.append(["address":address,"name":String((row["name"] as? String ?? "NAS UGREEN").prefix(128)),"model":String((row["model"] as? String ?? "").prefix(64))])}
        }
    }
    return results
}
private func discoverNAS() async throws -> [[String:String]] {
    let config=URLSessionConfiguration.ephemeral;config.httpShouldSetCookies=false;config.httpCookieStorage=nil;config.urlCredentialStorage=nil;config.requestCachePolicy = .reloadIgnoringLocalCacheData;config.timeoutIntervalForRequest=15;config.timeoutIntervalForResource=20
    let session=URLSession(configuration:config,delegate:DiscoveryRedirectPolicy(),delegateQueue:nil);defer{session.invalidateAndCancel()}
    var request=URLRequest(url:URL(string:"https://api.ugnas.com/api/device/v1/ua/network/match")!);request.httpMethod="POST";request.httpBody=Data("{}".utf8);request.setValue("application/json",forHTTPHeaderField:"Content-Type")
    let (data,response)=try await session.data(for:request)
    guard let http=response as? HTTPURLResponse,http.statusCode==200 else {throw fail(L("ui_6772a23b59ca", "Le service de recherche UGREEN est indisponible."))}
    return try discoveredNAS(data)
}

private struct FileLabel:Codable {var ext:String?;var name:String?}
private struct LabelJob:Codable {
    var sourceHash:String;var directory:String;var previousIDs:[String];var label:FileLabel;var created:Date;var taskID:String?
}
private func safeFilename(_ raw:String) -> String? {
    var name=raw.precomposedStringWithCanonicalMapping.components(separatedBy:CharacterSet(charactersIn:"\\/:*?\"<>|\r\n\0").union(.controlCharacters)).joined(separator:" ").trimmingCharacters(in:.whitespacesAndNewlines)
    if name.utf8.count>220 {
        let ext=(name as NSString).pathExtension
        if ext.range(of:"^[a-zA-Z0-9]{1,12}$",options:.regularExpression) != nil {
            var stem=(name as NSString).deletingPathExtension
            while (stem+"."+ext).utf8.count>220{stem.removeLast()};name=stem+"."+ext
        }else{while name.utf8.count>220{name.removeLast()}}
    }
    guard !name.isEmpty,name != ".",name != "..",!name.hasPrefix(".") else {return nil};return name
}
private func dispositionName(_ value:String?) -> String? {
    guard let value else {return nil}
    func capture(_ pattern:String)->String? {guard let r=try? NSRegularExpression(pattern:pattern,options:.caseInsensitive),let m=r.firstMatch(in:value,range:NSRange(value.startIndex...,in:value)),let range=Range(m.range(at:1),in:value) else{return nil};return String(value[range])}
    if let encoded=capture("(?:^|;)\\s*filename\\*\\s*=\\s*UTF-8'[^']*'([^;]+)"),let decoded=encoded.trimmingCharacters(in:.whitespaces).removingPercentEncoding {return safeFilename(decoded)}
    return (capture("(?:^|;)\\s*filename\\s*=\\s*\"([^\"]*)\"") ?? capture("(?:^|;)\\s*filename\\s*=\\s*([^;]+)")).flatMap{safeFilename($0)}
}
private func mimeExtension(_ mime:String) -> String? {
    let type=mime.lowercased().components(separatedBy:";")[0].trimmingCharacters(in:.whitespaces)
    guard !["application/octet-stream","binary/octet-stream","application/unknown"].contains(type) else{return nil}
    let aliases=["audio/mp4":"m4a","audio/x-m4a":"m4a","image/jpeg":"jpg","application/x-rar-compressed":"rar","application/x-7z-compressed":"7z","application/x-apple-diskimage":"dmg","application/vnd.microsoft.portable-executable":"exe"]
    let ext=aliases[type] ?? UTType(mimeType:type)?.preferredFilenameExtension
    guard let ext,ext.range(of:"^[a-zA-Z0-9]{1,12}$",options:.regularExpression) != nil else{return nil};return ext.lowercased()
}
private func magicExtension(_ data:Data)->String? {
    let b=[UInt8](data)
    func starts(_ bytes:[UInt8])->Bool {b.starts(with:bytes)}
    if starts([0xff,0xd8,0xff]) {return "jpg"}
    if starts([137,80,78,71,13,10,26,10]) {return "png"}
    if starts(Array("GIF87a".utf8)) || starts(Array("GIF89a".utf8)) {return "gif"}
    if starts(Array("%PDF-".utf8)) {return "pdf"}
    if starts([0x50,0x4b,3,4]) || starts([0x50,0x4b,5,6]) || starts([0x50,0x4b,7,8]) {return "zip"}
    if starts([0x37,0x7a,0xbc,0xaf,0x27,0x1c]) {return "7z"}
    if starts(Array("Rar!".utf8)) {return "rar"}
    if starts([0x1f,0x8b]) {return "gz"}
    if starts(Array("OggS".utf8)) {return "ogg"}
    if starts(Array("fLaC".utf8)) {return "flac"}
    if starts(Array("ID3".utf8)) {return "mp3"}
    if b.count>=12,Array(b[0..<4])==Array("RIFF".utf8) {let kind=Array(b[8..<12]);if kind==Array("WEBP".utf8){return "webp"};if kind==Array("WAVE".utf8){return "wav"};if kind==Array("AVI ".utf8){return "avi"}}
    if b.count>=16,Array(b[4..<8])==Array("ftyp".utf8) {
        let brand=String(bytes:b[8..<12],encoding:.ascii) ?? ""
        if ["avif","avis"].contains(brand){return "avif"}
        if ["heic","heix","hevc","hevx"].contains(brand){return "heic"}
        if brand=="qt  "{return "mov"}
        if ["M4A ","M4B ","M4P "].contains(brand){return brand=="M4B " ? "m4b" : "m4a"}
        if brand=="M4V "{return "m4v"}
        if brand.hasPrefix("3gp"){return "3gp"}
        if brand.hasPrefix("3g2"){return "3g2"}
        if ["isom","iso2","mp41","mp42","avc1","dash"].contains(brand){return "mp4"}
        // ftyp identifies a container family, not necessarily MP4 video.
        return nil
    }
    // PE needs its signature as well as MZ; MZ alone also describes DOS files.
    if starts([0x4d,0x5a]),b.count>=64 {let offset=Int(b[60])|Int(b[61])<<8|Int(b[62])<<16|Int(b[63])<<24;if offset>=0,offset+4<=b.count,Array(b[offset..<offset+4])==[80,69,0,0]{return "exe"}}
    return nil
}
private func inferredLabel(headers:HTTPURLResponse,bytes:Data)->FileLabel {
    let name=dispositionName(headers.value(forHTTPHeaderField:"Content-Disposition"))
    let declared=headers.mimeType.flatMap{mimeExtension($0)},magic=magicExtension(bytes)
    let nameExt=name.map{($0 as NSString).pathExtension.lowercased()}.flatMap{$0.isEmpty ? nil:$0}
    let containers:Set<String>=["docx","xlsx","pptx","odt","ods","odp","epub","jar","apk"]
    var ext=magic=="zip" && (containers.contains(nameExt ?? "") || containers.contains(declared ?? "")) ? (containers.contains(nameExt ?? "") ? nameExt : declared) : magic ?? declared ?? nameExt
    if magic=="mp4" {
        let variants:Set<String>=["m4a","m4b","m4v","3gp","3g2","mov"]
        if variants.contains(declared ?? ""){ext=declared}
        else if variants.contains(nameExt ?? ""){ext=nameExt}
    }
    return FileLabel(ext:ext,name:name)
}
private final class FileProbePolicy:NSObject,URLSessionTaskDelegate,@unchecked Sendable {
    private var redirects=0
    func urlSession(_ session:URLSession,task:URLSessionTask,willPerformHTTPRedirection response:HTTPURLResponse,newRequest request:URLRequest,completionHandler:@escaping(URLRequest?)->Void) {
        redirects+=1
        guard redirects<=5,let url=request.url,["http","https"].contains(url.scheme?.lowercased() ?? ""),url.user==nil,url.password==nil,!(response.url?.scheme=="https" && url.scheme != "https") else{completionHandler(nil);return}
        var clean=request;clean.setValue(nil,forHTTPHeaderField:"Authorization");clean.setValue(nil,forHTTPHeaderField:"Cookie");clean.setValue("bytes=0-8191",forHTTPHeaderField:"Range");completionHandler(clean)
    }
}
private func fileProbeRequest(_ url:URL)->URLRequest {
    var request=URLRequest(url:url)
    // Query URLs can be signed or single-use. Inspect headers without reading
    // their body a second time; the NAS retains the original URL untouched.
    if url.query != nil {request.httpMethod="HEAD"}else{request.setValue("bytes=0-8191",forHTTPHeaderField:"Range")}
    request.setValue("identity",forHTTPHeaderField:"Accept-Encoding");return request
}
private func probeFileLabel(_ raw:String) async -> FileLabel {
    guard let url=URL(string:raw),["http","https"].contains(url.scheme?.lowercased() ?? "") else{return FileLabel()}
    let config=URLSessionConfiguration.ephemeral;config.httpShouldSetCookies=false;config.httpCookieStorage=nil;config.urlCredentialStorage=nil;config.requestCachePolicy = .reloadIgnoringLocalCacheData;config.timeoutIntervalForRequest=8;config.timeoutIntervalForResource=12
    let session=URLSession(configuration:config,delegate:FileProbePolicy(),delegateQueue:nil);defer{session.invalidateAndCancel()}
    let request=fileProbeRequest(url)
    if request.httpMethod=="HEAD" {
        guard let(_,response)=try? await session.data(for:request),let http=response as? HTTPURLResponse,[200,206].contains(http.statusCode) else{return FileLabel()}
        return inferredLabel(headers:http,bytes:Data())
    }
    do {let(stream,response)=try await session.bytes(for:request);guard let http=response as? HTTPURLResponse,[200,206].contains(http.statusCode) else{return FileLabel()};var bytes=Data();for try await byte in stream {bytes.append(byte);if bytes.count>=8192{break}};return inferredLabel(headers:http,bytes:bytes)}catch{return FileLabel()}
}
private func labelledName(_ raw:String,_ label:FileLabel)->String? {
    guard let ext=label.ext,ext.range(of:"^[a-zA-Z0-9]{1,12}$",options:.regularExpression) != nil,let original=safeFilename(raw) else{return nil}
    let current=label.name.flatMap{safeFilename($0)} ?? original
    let old=(current as NSString).pathExtension.lowercased()
    let aliases:Set<String>=ext=="jpg" ? ["jpg","jpeg","jpe"] : ext=="tiff" ? ["tiff","tif"] : [ext]
    if aliases.contains(old){return current}
    if ext=="m4a",["m4a","m4b","m4p"].contains(old){return current}
    if ext=="mp4",["m4a","m4b","m4v","3gp","3g2","mov"].contains(old){return current}
    if ext=="txt",let existing=UTType(filenameExtension:old),existing.conforms(to:.text){return current}
    if ext=="zip",["docx","xlsx","pptx","odt","ods","odp","epub","jar","apk"].contains(old){return current}
    // Preserve NAS collision suffixes such as photo.1, then append the real type.
    let numeric=old.range(of:"^[0-9]+$",options:.regularExpression) != nil
    let base=old.isEmpty || numeric ? current : (current as NSString).deletingPathExtension
    return safeFilename(base+"."+ext)
}
private func labelPath(directory:String,name:String)->String? {
    guard directory.hasPrefix("/"),!directory.split(separator:"/").contains(".."),!name.isEmpty,name != ".",name != "..",name.utf8.count<=255,!name.contains(where:{$0=="/" || $0=="\\" || $0.isNewline || $0=="\0"}) else{return nil}
    return (directory as NSString).appendingPathComponent(name)
}
private func sourceDigest(_ raw:String)->String {SHA256.hash(data:Data(raw.utf8)).map{String(format:"%02x",$0)}.joined()}
private func matchesLabelJob(_ row:[String:Any],_ job:LabelJob)->Bool {
    guard let kind=row["link_type"] as? Int,![6,7].contains(kind) else{return false}
    let id=String(describing:row["id"] ?? "")
    guard !id.isEmpty,!job.previousIDs.contains(id),sourceDigest(row["download_url"] as? String ?? "")==job.sourceHash,nasSaveDirectory(row["save_dir"] as? String ?? "")==job.directory else{return false}
    return job.taskID==nil || job.taskID==id
}
private actor NAS {
    static let shared=NAS()
    private var busy=false
    private var taskNames:[String:String]=[:]
    private let pendingPrefix="ugreen.pendingCertificate."
    private var lastFailedLogin:[String:Date]=[:]
    func handle(_ m:[String:Any],profile:String) async -> [String:Any] {
        if m["command"] as? String == "notificationStatus" {return await DownloadNotifications.status()}
        if m["command"] as? String == "disableNotifications" {
            UserDefaults.standard.set(false,forKey:"ugreen.notificationsEnabled."+profile)
            return ["ok":true]
        }
        guard !busy else {return ["ok":false,"busy":true,"error":L("ui_89450dc3c8e2", "Une opération NAS est déjà en cours.")]}
        busy=true;defer{busy=false}
        do {
            switch m["command"] as? String {
            case "discover":
                return ["ok":true,"devices":try await discoverNAS()]
            case "status":
                guard let a=try Vault.read(profile) else {return ["ok":true,"configured":false]}
                return ["ok":true,"configured":true,"address":a.address,"username":a.username,"saveDir":a.saveDir,"fingerprint":a.fingerprint]
            case "probe":
                let u=try endpoint(m["address"] as? String ?? "")
                let transport=Transport(host:u.host!,pin:nil)
                var request=URLRequest(url:u.appendingPathComponent("ugreen/v1/verify/check"));request.httpMethod="POST";request.httpBody=Data("{}".utf8);request.setValue("application/json",forHTTPHeaderField:"Content-Type")
                _ = try await transport.perform(request)
                guard let pin=transport.observed else {throw fail(L("ui_03bfba1ab6f4", "Certificat NAS indisponible."))}
                let id=UUID().uuidString
                UserDefaults.standard.set(["id":id,"address":u.absoluteString,"pin":pin,"date":Date()],forKey:pendingPrefix+profile)
                return ["ok":true,"candidate":id,"fingerprint":pin]
            case "configure":
                let u=try endpoint(m["address"] as? String ?? "")
                guard let id=m["candidate"] as? String,let candidate=UserDefaults.standard.dictionary(forKey:pendingPrefix+profile),candidate["id"] as? String==id,candidate["address"] as? String==u.absoluteString,let pin=candidate["pin"] as? String,let date=candidate["date"] as? Date,Date().timeIntervalSince(date)<300 else {throw fail(L("ui_094557fca057", "Vérifiez de nouveau le certificat avant d’enregistrer le compte."))}
                UserDefaults.standard.removeObject(forKey:pendingPrefix+profile)
                let user=(m["username"] as? String ?? "").trimmingCharacters(in:.whitespacesAndNewlines)
                let old=try Vault.read(profile)
                var password=m["password"] as? String ?? ""
                if password.isEmpty,let old=old,old.address==u.absoluteString,old.username==user {password=old.password}
                let dir=m["saveDir"] as? String ?? ""
                guard !user.isEmpty,!password.isEmpty,dir.hasPrefix("/"),dir.count<2048,!dir.contains(where:{$0.isNewline || $0=="\0"}) else {throw fail(L("ui_7143f9a88e8f", "Identifiants ou dossier de destination incomplets."))}
                var a=Account(address:u.absoluteString,username:user,password:password,fingerprint:pin,saveDir:dir,clientID:old?.clientID ?? UUID().uuidString,token:nil,authType:nil)
                try await login(&a,profile:profile,otp:m["otp"] as? String ?? "",trustDevice:m["trustDevice"] as? Bool ?? false);try Vault.write(a,profile)
                return ["ok":true,"message":L("ui_d82863a8cab7", "Connexion réussie. Identifiants et session enregistrés dans le Trousseau.")]
            case "forget":if let a=try Vault.read(profile){UserDefaults.standard.removeObject(forKey:labelKey(a,profile:profile))};try Vault.remove(profile);return ["ok":true]
            case "labelDownloads":
                guard var a=try Vault.read(profile),!readLabelJobs(a,profile:profile).isEmpty else{return ["ok":true]}
                if a.token==nil {try await login(&a,profile:profile)}
                try await repairLabels(&a,profile:profile)
                return ["ok":true]
            case "heartbeat":
                guard let a=try Vault.read(profile),a.token != nil else {return ["ok":true]}
                do {_ = try await request(a,"GET","ugreen/v1/verify/heartbeat");return ["ok":true]} catch {return ["ok":false,"error":L("ui_4bb0c308d018", "Session à renouveler lors du prochain envoi.")]}
            case "enableNotifications":
                let allowed=try await UNUserNotificationCenter.current().requestAuthorization(options:[.alert,.sound])
                if allowed {UserDefaults.standard.set(true,forKey:"ugreen.notificationsEnabled."+profile)}
                if allowed,let a=try Vault.read(profile) {
                    // Start with a fresh baseline after enabling; no alerts for events during the pause.
                    let snapshot="ugreen.downloadSnapshot."+profile+"|"+a.address+"|"+a.username
                    UserDefaults.standard.removeObject(forKey:snapshot)
                    UserDefaults.standard.removeObject(forKey:snapshot+".pending")
                    UserDefaults.standard.removeObject(forKey:snapshot+".completed")
                }
                return ["ok":allowed,"error":allowed ? "" : L("ui_6b7a96d5703e", "Autorisez les notifications dans Réglages Système → Notifications.")]
            case "testNotification":
                try await DownloadNotifications.send(id:"ugreen-notification-test",title:"Notification de test",body:"Les notifications de UGREEN NAS Download fonctionnent sur ce Mac.")
                return ["ok":true]
            case "downloads","monitorDownloads":
                guard var a=try Vault.read(profile) else {return ["ok":false,"needsSetup":true,"error":L("ui_207aa6d45769", "Configurez votre NAS dans les réglages.")]}
                if a.token == nil {try await login(&a,profile:profile)}
                var rows:[[String:Any]]=[]
                var page=1;var total=0
                repeat {
                    let path="ugreen/v1/downloadCenter/download/getListV3?page=\(page)&page_size=50"
                    var response:[String:Any]
                    do {response=try await request(a,"GET",path)}
                    catch ClientError.expired {try await recover(&a,profile:profile);response=try await request(a,"GET",path)}
                    guard let data=response["data"] as? [String:Any] else {throw fail(L("ui_409c39d465ec", "Liste des téléchargements reçue dans un format inattendu."))}
                    let batch=try downloadBatch(data)
                    total=downloadTotal(data) ?? rows.count+batch.count+(batch.count==50 ? 1:0)
                    rows.append(contentsOf:batch)
                    if downloadPageFinished(data,batchCount:batch.count,receivedCount:rows.count) {break}
                    page+=1
                } while page<=200
                var tasks=downloadRows(rows)
                for index in tasks.indices where tasks[index]["name"] as? String=="Téléchargement sans nom" {
                    guard let id=tasks[index]["id"] as? String,!id.isEmpty,id.range(of:"^[a-zA-Z0-9_-]+$",options:.regularExpression) != nil else {continue}
                    let key=profile+"|"+a.address+"|"+a.username+"|"+id
                    if let name=taskNames[key] {tasks[index]["name"]=name;continue}
                    if let detail=try? await request(a,"GET","ugreen/v1/downloadCenter/complete/getTaskInfo?id=\(id)"),let data=detail["data"] as? [String:Any],let name=data["task_name"] as? String,!name.isEmpty,name != "/" {
                        tasks[index]["name"]=String(name.prefix(1024));taskNames[key]=String(name.prefix(1024))
                    }
                    if tasks[index]["name"] as? String=="Téléchargement sans nom",
                       let resources=try? await request(a,"GET","ugreen/v1/downloadCenter/complete/getTaskResourceList?id=\(id)"),
                       let data=resources["data"] as? [String:Any],let files=data["result"] as? [[String:Any]],let first=files.first {
                        let fileName=(first["file_name"] as? String).flatMap{!$0.isEmpty && $0 != "/" ? $0 : nil} ?? (first["path"] as? String).map{URL(fileURLWithPath:$0).lastPathComponent}
                        if let fileName=fileName,!fileName.isEmpty,fileName != "/" {
                            let name=String((fileName+(files.count>1 ? " (+\(files.count-1) fichiers)" : "")).prefix(1024))
                            tasks[index]["name"]=name;taskNames[key]=name
                        }
                    }
                }
                if taskNames.count>1000 {taskNames.removeAll()}
                if m["command"] as? String == "monitorDownloads" {
                    let key="ugreen.downloadSnapshot."+profile+"|"+a.address+"|"+a.username
                    let previous=UserDefaults.standard.array(forKey:key) as? [[String:Any]]
                    let completedKey=key+".completed"
                    let knownCompleted=(UserDefaults.standard.array(forKey:completedKey) as? [String]).map{Set($0)}
                    var completeRows:[[String:Any]]=[]
                    var completePage=1
                    while completePage<=200 {
                        let response:[String:Any]
                        do{response=try await request(a,"GET","ugreen/v1/downloadCenter/complete/getListV2?page=\(completePage)&page_size=50")}
                        catch ClientError.expired{try await recover(&a,profile:profile);response=try await request(a,"GET","ugreen/v1/downloadCenter/complete/getListV2?page=\(completePage)&page_size=50")}
                        guard let data=response["data"] as? [String:Any] else{throw fail(L("ui_e15ebf8c3f20", "Liste des fichiers terminés indisponible."))}
                        let batch=try downloadBatch(data);completeRows.append(contentsOf:batch)
                        if downloadPageFinished(data,batchCount:batch.count,receivedCount:completeRows.count){break}
                        completePage+=1
                    }
                    guard completePage<=200 else{throw fail(L("ui_ce120d12a24d", "Trop de fichiers terminés pour assurer un suivi complet des notifications."))}
                    let completed=downloadRows(completeRows.map{row in var row=row;row["task_status"]=2;return row}).map{row in var row=row;row["state"]=3;return row}
                    var current=tasks+completed
                    var pending=UserDefaults.standard.array(forKey:key+".pending") as? [[String:Any]] ?? []
                    for old in previous ?? [] {
                        guard let id=old["id"] as? String,!id.isEmpty,!current.contains(where:{$0["id"] as? String==id}) else {continue}
                        // A vanished task is never assumed complete: confirm its state with the NAS.
                        if rows.count>=total,id.range(of:"^[a-zA-Z0-9_-]+$",options:.regularExpression) != nil,
                           let detail=try? await request(a,"GET","ugreen/v1/downloadCenter/complete/getTaskInfo?id=\(id)"),
                           let data=detail["data"] as? [String:Any], let state=(data["task_status"] as? NSNumber) ?? (((data["download_completed_time"] as? NSNumber)?.doubleValue ?? 0)>0 ? NSNumber(value:3) : nil),state.intValue==3 {
                            current.append(["id":id,"name":old["name"] ?? L("ui_38858cd588e0", "Téléchargement"),"state":3])
                        }
                    }
                    for event in newDownloadEvents(previous:previous,current:current,knownCompleted:knownCompleted) {
                        pending.append(["id":UUID().uuidString,"title":event["title"] ?? L("ui_38858cd588e0", "Téléchargement"),"name":String((event["name"] as? String ?? L("ui_38858cd588e0", "Téléchargement")).prefix(1024))])
                    }
                    let completedIDs=Set(completed.compactMap{$0["id"] as? String})
                    UserDefaults.standard.set(Array((knownCompleted ?? []).union(completedIDs)).sorted().suffix(10000).map{$0},forKey:completedKey)
                    // Store only names, IDs and states. No session or torrent URLs.
                    UserDefaults.standard.set(current.suffix(10000).map{["id":$0["id"] ?? "","name":$0["name"] ?? "Torrent","state":$0["state"] ?? 0]},forKey:key)
                    UserDefaults.standard.set(pending,forKey:key+".pending")
                    while let event=pending.first {
                        if UserDefaults.standard.object(forKey:"ugreen.notificationsEnabled."+profile) as? Bool == false {
                            UserDefaults.standard.removeObject(forKey:key+".pending");break
                        }
                        try await DownloadNotifications.send(id:"ugreen-"+(event["id"] as? String ?? "event"),title:event["title"] as? String ?? L("ui_38858cd588e0", "Téléchargement"),body:event["name"] as? String ?? "Torrent")
                        pending.removeFirst();UserDefaults.standard.set(pending,forKey:key+".pending")
                    }
                }
                return ["ok":true,"downloads":tasks,"truncated":rows.count<total]
            case "send","sendTorrent","sendDownload":
                let isFile=m["command"] as? String=="sendTorrent"
                let file=isFile ? try torrentData(m["data"] as? String ?? "") : nil
                let value=isFile ? "" : try (m["command"] as? String == "sendDownload" ? downloadLink(m["link"] as? String ?? "") : link(m["link"] as? String ?? ""))
                guard var a=try Vault.read(profile) else {return ["ok":false,"needsSetup":true,"error":L("ui_ffe11a4deea9", "Configurez votre NAS dans les options de l’extension.") ]}
                if a.token == nil {try await login(&a,profile:profile)}
                else {
                    do {_ = try await request(a,"GET","ugreen/v1/verify/is_login")}
                    catch ClientError.expired {try await recover(&a,profile:profile)}
                }
                let saveDir=nasSaveDirectory(a.saveDir)
                let sourceURL=URL(string:value)
                let labelAllowed=m["command"] as? String == "sendDownload" && ["http","https"].contains(sourceURL?.scheme?.lowercased() ?? "") && sourceURL?.pathExtension.lowercased() != "torrent"
                let label=labelAllowed ? await probeFileLabel(value) : FileLabel()
                var labelJob:LabelJob?
                if label.ext != nil,label.ext != "torrent" {
                    let before:[[String:Any]]
                    do{before=try await labelRows(a)}catch ClientError.expired{try await recover(&a,profile:profile);before=try await labelRows(a)}
                    labelJob=LabelJob(sourceHash:sourceDigest(value),directory:saveDir,previousIDs:before.map{String(describing:$0["id"] ?? "")},label:label,created:Date(),taskID:nil)
                }
                let boundary="UGREEN-"+UUID().uuidString
                var body=Data()
                for (key,value) in (isFile ? [("save_dir",saveDir),("is_batch","false")] : [("download_url",value),("save_dir",saveDir),("is_batch","false")]) {body.append(Data("--\(boundary)\r\nContent-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)\r\n".utf8))}
                if let file=file {
                    body.append(Data("--\(boundary)\r\nContent-Disposition: form-data; name=\"file\"; filename=\"Safari.torrent\"\r\nContent-Type: application/x-bittorrent\r\n\r\n".utf8));body.append(file);body.append(Data("\r\n".utf8))
                }
                let path="ugreen/v1/downloadCenter/download/add"
                body.append(Data("--\(boundary)--\r\n".utf8))
                var response:[String:Any]
                do {response=try await request(a,"POST",path,body:body,contentType:"multipart/form-data; boundary=\(boundary)")}
                catch ClientError.expired {try await recover(&a,profile:profile);response=try await request(a,"POST",path,body:body,contentType:"multipart/form-data; boundary=\(boundary)")}
                // Retry only an explicit authentication rejection, never a timeout or ambiguous response.
                let data=response["data"] as? [String:Any] ?? [:]
                guard (data["status"] as? Int ?? (isFile ? data["result"] as? Int : nil))==0 else {let code=data["status"] as? Int ?? -1;throw fail(L("ui_85d198010d47", "Tâche non confirmée par le NAS (état %d). Vérifiez Téléchargements avant de réessayer.", code))}
                if var selected=try resourceImport(data) {
                    selected["save_dir"]=saveDir
                    let payload=try JSONSerialization.data(withJSONObject:selected)
                    let commitPath="ugreen/v1/downloadCenter/download/downloadFile"
                    let confirmation:[String:Any]
                    do {confirmation=try await request(a,"POST",commitPath,body:payload,contentType:"application/json")}
                    catch ClientError.expired {try await recover(&a,profile:profile);confirmation=try await request(a,"POST",commitPath,body:payload,contentType:"application/json")}
                    let result=confirmation["data"] as? [String:Any] ?? [:]
                    if let status=result["status"] as? Int ?? result["result"] as? Int,status != 0 {throw fail(L("ui_353a6a7f7fa5", "Le NAS n’a pas confirmé les fichiers (état %d). Vérifiez Téléchargements avant de réessayer.", status))}
                } else if isFile {
                    throw fail(L("ui_bcdcbe57a1af", "Le NAS n’a retourné aucun fichier à confirmer. Vérifiez Téléchargements avant de réessayer."))
                }
                if let labelJob {
                    var jobs=readLabelJobs(a,profile:profile);jobs.append(labelJob);saveLabelJobs(jobs,a,profile:profile)
                    try? await repairLabels(&a,profile:profile)
                }
                return ["ok":true,"message":L("ui_ecf3d342b3b1", "Tâche acceptée par Téléchargements du NAS.")+(labelAllowed && label.ext==nil && ((URL(string:value)?.lastPathComponent ?? "") as NSString).pathExtension.isEmpty ? L("ui_8534c1e85d41", " Type non identifié : le nom d’origine sera conservé.") : "")]

            default:throw fail(L("ui_ee8668932e6f", "Commande non prise en charge."))
            }
        } catch ClientError.message(let message) {return ["ok":false,"error":message]}
        catch ClientError.expired {return ["ok":false,"error":L("ui_b67e827b8e82", "Session refusée. Vérifiez les identifiants dans les options.")]}
        catch {
            let e=error as NSError
            if e.domain==NSURLErrorDomain {
                switch e.code {
                case NSURLErrorCannotFindHost,NSURLErrorDNSLookupFailed:
                    return ["ok":false,"error":L("ui_5ecb5bf8600a", "Nom du NAS introuvable (DNS). Ouvrez l’application UGREEN NAS Download et autorisez le réseau local, puis réessayez. Vous pouvez aussi vérifier l’adresse IP du NAS dans les options.")]
                case NSURLErrorNotConnectedToInternet,NSURLErrorCannotConnectToHost:
                    return ["ok":false,"error":L("ui_7a3c2b255cb4", "Connexion locale refusée ou NAS inaccessible. Dans l’application Mac, utilisez Autoriser la connexion au réseau local, puis vérifiez l’adresse et le port.")]
                case NSURLErrorSecureConnectionFailed,NSURLErrorServerCertificateUntrusted,NSURLErrorServerCertificateHasBadDate:
                    return ["ok":false,"error":L("ui_8872b03932e1", "Connexion TLS ou certificat refusé. Vérifiez le certificat et son empreinte dans les options avant de réessayer.")]
                case NSURLErrorTimedOut:
                    return ["ok":false,"error":L("ui_eb93e7cae9e6", "Délai de connexion au NAS dépassé. Vérifiez le réseau et les tâches avant un nouvel envoi.")]
                default:break
                }
            }
            return ["ok":false,"error":L("ui_6efc97ce913e", "Connexion NAS non confirmée (code technique %d). Vérifiez les tâches avant de réessayer.", e.code)]
        }
    }

    private func labelKey(_ a:Account,profile:String)->String {"ugreen.fileLabels."+profile+"|"+a.address+"|"+a.username}
    private func readLabelJobs(_ a:Account,profile:String)->[LabelJob] {
        guard let data=UserDefaults.standard.data(forKey:labelKey(a,profile:profile)),let jobs=try? JSONDecoder().decode([LabelJob].self,from:data) else{return []}
        return jobs.filter{Date().timeIntervalSince($0.created)<7*86400}
    }
    private func saveLabelJobs(_ jobs:[LabelJob],_ a:Account,profile:String) {UserDefaults.standard.set(try? JSONEncoder().encode(Array(jobs.suffix(100))),forKey:labelKey(a,profile:profile))}
    private func labelRows(_ a:Account) async throws -> [[String:Any]] {
        var rows:[[String:Any]]=[]
        for endpoint in ["download/getListV3","complete/getListV2"] {
            var page=1
            while page<=200 {
                let r=try await request(a,"GET","ugreen/v1/downloadCenter/\(endpoint)?page=\(page)&page_size=50")
                guard let d=r["data"] as? [String:Any] else{throw fail(L("ui_d8dc23336417", "Liste indisponible pour identifier le fichier."))}
                let batch=try downloadBatch(d)
                rows.append(contentsOf:batch.map{var row=$0;row["_complete"]=endpoint.hasPrefix("complete/");return row})
                if downloadPageFinished(d,batchCount:batch.count,receivedCount:page*50){break};page+=1
            }
            guard page<=200 else{throw fail(L("ui_51e3ca1fd3aa", "Trop de tâches pour identifier sûrement le fichier."))}
        }
        return rows
    }
    private func repairLabels(_ a:inout Account,profile:String) async throws {
        var jobs=readLabelJobs(a,profile:profile);guard !jobs.isEmpty else{return}
        let rows:[[String:Any]]
        do{rows=try await labelRows(a)}catch ClientError.expired{try await recover(&a,profile:profile);rows=try await labelRows(a)}
        var pending:[LabelJob]=[]
        var firstError:Error?
        for var job in jobs {
            let matches=rows.filter{matchesLabelJob($0,job)}
            guard matches.count==1,let row=matches.first else{pending.append(job);continue}
            let id=String(describing:row["id"] ?? "");job.taskID=id
            guard row["_complete"] as? Bool == true else{pending.append(job);continue}
            guard let raw=row["download_file_name"] as? String,let renamed=labelledName(raw,job.label),let path=labelPath(directory:job.directory,name:raw),let destination=labelPath(directory:job.directory,name:renamed) else{
                pending.append(job)
                if firstError==nil{firstError=fail(L("ui_3638a59bd40e", "Le NAS n’a pas fourni un nom de fichier utilisable. Le renommage reste en attente."))}
                continue
            }
            if raw==renamed{continue}
            do {
                var chosen=renamed;var target=destination
                var free=false
                for index in 0...99 {
                    if index>0 {
                        var stem=(renamed as NSString).deletingPathExtension
                        let ext=(renamed as NSString).pathExtension
                        while (stem+" (\(index))."+ext).utf8.count>220{stem.removeLast()}
                        guard let candidate=safeFilename(stem+" (\(index))."+ext),let candidatePath=labelPath(directory:job.directory,name:candidate) else{break}
                        chosen=candidate;target=candidatePath
                    }
                    let exists=try await request(a,"POST","ugreen/v1/filemgr/pathExist",body:JSONSerialization.data(withJSONObject:["path":target]),contentType:"application/json")
                    let data=exists["data"] as? [String:Any] ?? [:]
                    guard let present=(data["exist"] ?? data["exists"] ?? data["result"]) as? Bool else{throw fail(L("ui_eb63290d0d8b", "Le NAS ne confirme pas si le nom de destination est libre."))}
                    if !present{free=true;break}
                }
                guard free else{throw fail(L("ui_201901522851", "Aucun nom de fichier libre. Aucun fichier n’a été remplacé."))}
                _ = try await request(a,"POST","ugreen/v2/filemgr/rename",body:JSONSerialization.data(withJSONObject:["path":path,"new_name":chosen]),contentType:"application/json")
            }catch {pending.append(job);if firstError==nil{firstError=error}}
        }
        jobs=pending;saveLabelJobs(jobs,a,profile:profile)
        if let firstError{throw firstError}
    }
    private func request(_ a:Account,_ method:String,_ path:String,body:Data?=nil,contentType:String?=nil,authenticated:Bool=true) async throws -> [String:Any] {
        let base=try endpoint(a.address)
        guard let relative=URLComponents(string:path),let relativePath=relative.path.removingPercentEncoding else {throw fail(L("ui_32a1a240c4e6", "Chemin API invalide."))}
        var components=URLComponents(url:base.appendingPathComponent(relativePath),resolvingAgainstBaseURL:false)!
        components.queryItems=relative.queryItems
        if authenticated,let token=a.token {var items=components.queryItems ?? [];items.append(URLQueryItem(name:"token",value:token));components.queryItems=items}
        var r=URLRequest(url:components.url!);r.httpMethod=method;r.httpBody=body
        r.setValue("application/json",forHTTPHeaderField:"Accept");r.setValue("PC/WEB",forHTTPHeaderField:"UG-Agent")
        r.setValue(a.clientID,forHTTPHeaderField:"Client-Id");r.setValue(a.clientID,forHTTPHeaderField:"UG-Client-Id")
        r.setValue("1.20.0",forHTTPHeaderField:"Client-Version");r.setValue("fr-FR",forHTTPHeaderField:"X-Specify-Language")
        if let ct=contentType {r.setValue(ct,forHTTPHeaderField:"Content-Type")}
        if authenticated,let token=a.token {r.setValue(token,forHTTPHeaderField:"X-Ugreen-Token")}
        let (data,http)=try await Transport(host:base.host!,pin:a.fingerprint).perform(r)
        if http.statusCode==401 {throw ClientError.expired}
        guard http.statusCode==200,let payload=try JSONSerialization.jsonObject(with:data) as? [String:Any] else {throw fail(L("ui_ab3b50f251b3", "Réponse HTTP NAS inattendue."))}
        let code=payload["code"] as? Int ?? -1
        if [401,1024].contains(code) {throw ClientError.expired}
        if code==9406 {throw fail(L("ui_8493662e7e41", "Le NAS refuse les paramètres de connexion de ce client (code 9406). Vérifiez la version et le protocole de connexion."))}
        guard code==200 else {
            var message=String((payload["msg"] as? String ?? "").prefix(180))
            for secret in [a.password,a.token ?? ""] where !secret.isEmpty {message=message.replacingOccurrences(of:secret,with:"[masqué]")}
            throw fail(L("ui_e7bdf09e336a", "Le NAS refuse {path} (code %d). {message}", code).replacingOccurrences(of: "{path}", with: path).replacingOccurrences(of: "{message}", with: message))
        }
        var result=payload
        if let key=http.value(forHTTPHeaderField:"x-rsa-token") {result["_rsa"]=key}
        return result
    }
    private func login(_ a:inout Account,profile:String,otp:String="",trustDevice:Bool=false) async throws {
        guard otp.isEmpty || otp.range(of:"^[0-9]{6,8}$",options:.regularExpression) != nil else {throw fail(L("ui_00127e31a7b9", "Le code temporaire doit contenir 6 à 8 chiffres."))}
        if let last=lastFailedLogin[profile],Date().timeIntervalSince(last)<60 {throw fail(L("ui_a8d1da72b360", "Connexion récemment refusée. Vérifiez les options puis attendez une minute."))}
        do {
            let check=try await request(a,"POST","ugreen/v1/verify/check",body:JSONSerialization.data(withJSONObject:["username":a.username]),contentType:"application/json",authenticated:false)
            guard let raw=(check["_rsa"] ?? check["xRsaToken"]) as? String else {throw fail(L("ui_df225b598a79", "Le NAS n’a pas fourni sa clé RSA de connexion."))}
            let encrypted=try encryptPassword(a.password,key:rsaKey(raw))
            let payload=try await request(a,"POST","ugreen/v1/verify/login",body:JSONSerialization.data(withJSONObject:["username":a.username,"password":encrypted,"keepalive":true,"otp":true,"is_simple":true]),contentType:"application/json",authenticated:false)
            var data=payload["data"] as? [String:Any] ?? [:]
            if (data["token"] as? String)?.isEmpty != false, data["enable_otp"] as? Bool == true || data["token_id"] != nil {
                guard !otp.isEmpty,let tokenID=data["token_id"] else {throw fail(L("ui_1e5497bce01d", "Double authentification requise. Saisissez un code temporaire dans les options puis recommencez."))}
                let verification=try await request(a,"POST","ugreen/v1/verify/code/login",body:JSONSerialization.data(withJSONObject:["code":otp,"type":1,"token_id":tokenID,"trust":trustDevice,"trust_info":["client_type":"pc","system":"macOS","dev_name":"UGREEN NAS Download"]]),contentType:"application/json",authenticated:false)
                data=verification["data"] as? [String:Any] ?? [:]
            }
            guard let token=data["token"] as? String,!token.isEmpty else {throw fail(L("ui_2432f5f3cac4", "Connexion incomplète : validation supplémentaire demandée par le NAS."))}
            a.token=token;a.authType=data["auth_type"] as? String ?? "header"
            lastFailedLogin[profile]=nil;try Vault.write(a,profile)
        } catch {lastFailedLogin[profile]=Date();throw error}
    }
    private func recover(_ a:inout Account,profile:String) async throws {
        do {
            let result=try await request(a,"PUT","ugreen/v1/verify/refresh")
            if let data=result["data"] as? [String:Any],let token=data["token"] as? String,!token.isEmpty {a.token=token;try Vault.write(a,profile);return}
        } catch ClientError.expired {} catch ClientError.message(_) {} // explicit endpoint refusal can fall back to login
        try await login(&a,profile:profile)
    }
}
class SafariWebExtensionHandler: NSObject,NSExtensionRequestHandling {
    func beginRequest(with context:NSExtensionContext) {
        guard let item=context.inputItems.first as? NSExtensionItem,let message=item.userInfo?[SFExtensionMessageKey] as? [String:Any] else {context.cancelRequest(withError:fail(L("ui_86d4edf3510b", "Message invalide.")));return}
        let profile: String
        if #available(macOS 14.0, *) { profile=(item.userInfo?[SFExtensionProfileKey] as? UUID)?.uuidString ?? "default" } else {profile="default"}
        Task {
            let result=await NAS.shared.handle(message,profile:profile)
            let reply=NSExtensionItem();reply.userInfo=[SFExtensionMessageKey:result]
            context.completeRequest(returningItems:[reply],completionHandler:nil)
        }
    }
}
