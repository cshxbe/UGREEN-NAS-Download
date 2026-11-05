import Cocoa
import SafariServices
import WebKit
import Network

let extensionBundleIdentifier = "com.example.UGREENNASDownload.Extension"

class ViewController: NSViewController {
    // Keep the storyboard connection while replacing its web content with native controls.
    @IBOutlet var webView: WKWebView!
    private var networkProbe: NWConnection?
    private let connectionLabel=NSTextField(wrappingLabelWithString:"Autorisez le réseau local si macOS vous le demande.")
    private let extensionLabel=NSTextField(labelWithString:"Vérification de l’extension…")
    private var activationObserver:NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.isHidden=true
        let stack=NSStackView();stack.orientation = .vertical;stack.alignment = .centerX;stack.spacing=12
        stack.translatesAutoresizingMaskIntoConstraints=false
        view.addSubview(stack)
        NSLayoutConstraint.activate([stack.leadingAnchor.constraint(equalTo:view.leadingAnchor,constant:32),stack.trailingAnchor.constraint(equalTo:view.trailingAnchor,constant:-32),stack.topAnchor.constraint(equalTo:view.topAnchor,constant:28),stack.bottomAnchor.constraint(lessThanOrEqualTo:view.bottomAnchor,constant:-24)])
        let icon=NSImageView();icon.image=NSImage(named:"LargeIcon");icon.imageScaling = .scaleProportionallyUpOrDown
        icon.translatesAutoresizingMaskIntoConstraints=false
        NSLayoutConstraint.activate([icon.widthAnchor.constraint(equalToConstant:76),icon.heightAnchor.constraint(equalToConstant:76)])
        stack.addArrangedSubview(icon)
        let title=NSTextField(labelWithString:"UGREEN NAS Download");title.font = .systemFont(ofSize:22,weight:.semibold);title.alignment = .center
        stack.addArrangedSubview(title)
        let description=NSTextField(wrappingLabelWithString:"Dans Safari, faites un clic droit sur un fichier,\npuis choisissez « Télécharger sur le NAS ».")
        description.font = .systemFont(ofSize:13);description.textColor = .secondaryLabelColor;description.alignment = .center
        stack.addArrangedSubview(description);description.widthAnchor.constraint(equalTo:stack.widthAnchor).isActive=true
        extensionLabel.font = .systemFont(ofSize:12,weight:.medium);extensionLabel.alignment = .center
        stack.addArrangedSubview(extensionLabel)
        let settings=NSButton(title:"Réglages de l’extension dans Safari…",target:self,action:#selector(openPreferences))
        let network=NSButton(title:"Autoriser l’accès au NAS…",target:self,action:#selector(allowNetwork))
        for button in [settings,network] {
            button.bezelStyle = .rounded;button.controlSize = .large;button.font = .systemFont(ofSize:13)
            button.translatesAutoresizingMaskIntoConstraints=false;button.widthAnchor.constraint(equalToConstant:320).isActive=true
            button.heightAnchor.constraint(equalToConstant:34).isActive=true;stack.addArrangedSubview(button)
        }
        settings.keyEquivalent="\r"
        connectionLabel.font = .systemFont(ofSize:12);connectionLabel.textColor = .secondaryLabelColor;connectionLabel.alignment = .center
        stack.addArrangedSubview(connectionLabel)
        connectionLabel.widthAnchor.constraint(equalTo:stack.widthAnchor).isActive=true
        connectionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant:46).isActive=true
        refreshExtensionState()
        activationObserver=NotificationCenter.default.addObserver(forName:NSApplication.didBecomeActiveNotification,object:nil,queue:.main){[weak self] _ in self?.refreshExtensionState()}
    }
    deinit {if let activationObserver=activationObserver {NotificationCenter.default.removeObserver(activationObserver)}}
    private func refreshExtensionState() {
        SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier:extensionBundleIdentifier){[weak self] state,error in
            DispatchQueue.main.async {
                guard let self=self else {return}
                if let state=state,error==nil {
                    self.extensionLabel.stringValue=state.isEnabled ? "Extension activée dans Safari" : "Extension à activer dans les réglages Safari"
                    self.extensionLabel.textColor=state.isEnabled ? .systemGreen : .secondaryLabelColor
                } else {self.extensionLabel.stringValue="Ouvrez Safari pour vérifier l’extension.";self.extensionLabel.textColor = .secondaryLabelColor}
            }
        }
    }
    @objc private func openPreferences() {
        SFSafariApplication.showPreferencesForExtension(withIdentifier:extensionBundleIdentifier){[weak self] error in
            if error != nil {DispatchQueue.main.async {self?.networkStatus("Ouvrez Safari → Réglages → Extensions.")}}
        }
    }
    @objc private func allowNetwork(){authorizeNetwork()}
    private func networkStatus(_ text:String){connectionLabel.stringValue=text}
    private func authorizeNetwork() {
        networkProbe?.cancel()
        networkStatus("Connexion au NAS… Autorisez le réseau local si macOS le demande.")
        let probe=NWConnection(host:"ugreen.local",port:9443,using:.tcp)
        networkProbe=probe
        probe.stateUpdateHandler={ [weak self,weak probe] state in
            Task { @MainActor in
                guard let self=self,let probe=probe,self.networkProbe===probe else {return}
                switch state {
                case .ready:
                    self.networkStatus("Accès au réseau local disponible. Configurez ensuite votre NAS dans Safari.")
                    probe.cancel();self.networkProbe=nil
                case .waiting:
                    self.networkStatus("Autorisez l’accès dans Réglages Système → Confidentialité et sécurité → Réseau local.")
                case .failed:
                    self.networkStatus("Le NAS est inaccessible. Vérifiez votre connexion et l’accès au réseau local.")
                    probe.cancel();self.networkProbe=nil
                default:break
                }
            }
        }
        probe.start(queue:DispatchQueue(label:"UGREEN.NetworkAuthorization"))
        DispatchQueue.main.asyncAfter(deadline:.now()+30) { [weak self,weak probe] in
            guard let self=self,let probe=probe,self.networkProbe===probe else {return}
            probe.cancel();self.networkProbe=nil
            self.networkStatus("Le NAS ne répond pas. Vérifiez votre connexion, puis réessayez.")
        }
    }

}
