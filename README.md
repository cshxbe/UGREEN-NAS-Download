# UGREEN NAS Download

Une application macOS et une extension Safari pour envoyer des téléchargements à l’application **Téléchargements** d’un NAS UGREEN sous UGOS Pro, sans garder la page du NAS ouverte.

Version des sources : **0.5.2**. Projet communautaire indépendant, non affilié à UGREEN ou Apple.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="Extension/icon-dark-128.png">
  <img src="Extension/icon-128.png" width="96" height="96" alt="UGREEN NAS Download">
</picture>

## Fonctionnalités

- Interception des liens `.torrent` et `magnet:` sur les sites autorisés dans Safari.
- Action **Télécharger sur le NAS** par clic droit sur un lien, une image, une vidéo ou un élément audio directement accessible.
- Envoi manuel d’une URL depuis le menu de l’extension.
- Compte et session dans le Trousseau macOS ; prise en charge de la double authentification et de la confiance d’appareil.
- Recherche facultative du NAS par le service en ligne UGREEN, ou adresse HTTPS manuelle.
- Liste des téléchargements, progression et vitesse ; notifications facultatives de fin, d’arrêt et d’erreur.
- Identification des noms et types de fichiers HTTP, avec correction du nom après téléchargement lorsque le fichier est identifié sans ambiguïté.
- Icônes natives claire et sombre, et logos Safari adaptés au thème système.

## Compatibilité

Le projet est configuré pour **macOS 27 ou ultérieur** et a été compilé avec **Xcode 27.1**, pour Apple Silicon. Les essais NAS ont été réalisés avec un **DXP2800**, **UGOS Pro 1.20.0.0142** et **Téléchargements 1.19.1.0004**. Les autres versions ne sont pas garanties : l’intégration repose sur des API observées, sans contrat public stable d’UGREEN.

## Installer depuis le DMG

[Télécharger UGREEN NAS Download 0.5.2 pour Mac Apple Silicon](../../releases/tag/v0.5.2).

1. Ouvrir le DMG, glisser **UGREEN NAS Download** dans **Applications**, puis ouvrir l’app.
2. Dans **Safari → Réglages → Avancés**, activer les fonctionnalités pour les développeurs web. Dans **Développeur**, activer **Autoriser les extensions non signées**, puis activer **UGREEN NAS Download** dans **Extensions**.
3. Configurer le NAS dans les réglages de l’extension.

Ce paquet public est signé localement (ad hoc) et non notarié. macOS peut bloquer son ouverture initiale. Safari peut demander de réactiver l’autorisation des extensions non signées après avoir quitté le navigateur.

## Compiler depuis les sources

1. Cloner ce dépôt et ouvrir `Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj`.
2. Dans **Signing & Capabilities**, choisir votre propre équipe Apple pour les deux cibles : l’application et son extension. Aucune équipe personnelle n’est renseignée dans le dépôt.
3. Choisir le schéma **UGREEN NAS Download**, destination **My Mac**, puis compiler et lancer avec Xcode.
4. Activer l’extension dans **Safari → Réglages → Extensions**, puis autoriser les sites souhaités.
5. Ouvrir les réglages de l’extension et configurer votre NAS comme décrit ci-dessous.

Les identifiants de bundle d’exemple sont `com.example.UGREENNASDownload` et `com.example.UGREENNASDownload.Extension`. Si vous devez les personnaliser pour votre signature, modifier les identifiants du projet Xcode **et** les constantes correspondantes dans `Extension/background.js` et `ViewController.swift` : les valeurs doivent rester cohérentes.

Cette édition publique utilise des identifiants et un espace Trousseau distincts de l’application personnelle de développement. Elle exige sa propre configuration du NAS. La signature de développement ne constitue pas une distribution notariée et l’activation peut demander les réglages de développement Safari adaptés à votre signature.

Pour vérifier une compilation sans signature, depuis la racine du dépôt :

```sh
xcodebuild \
  -project "Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj" \
  -scheme "UGREEN NAS Download" \
  -configuration Release -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO build
```

Ce contrôle produit une application non signée ; utilisez votre équipe Apple pour une installation de développement utilisable dans Safari. Conserver l’arborescence du dépôt : les références Xcode vers `Extension` et `Design` sont relatives.

## Configurer le NAS

1. Saisir l’adresse HTTPS du NAS avec son port, votre identifiant et le chemin absolu de destination sur le NAS. Les champs personnels sont vides par défaut.
2. Cliquer **Vérifier le certificat du NAS**. Comparer l’empreinte SHA-256 avec une source de confiance avant de confirmer le certificat.
3. Saisir le mot de passe et, si nécessaire, un code de double authentification. La confiance de l’appareil est facultative ; sans elle, un nouveau code peut être nécessaire à l’expiration de la session.
4. Cliquer **Enregistrer et tester la connexion**. Autoriser l’accès au réseau local lorsque macOS le demande.
5. Activer l’interception automatique des torrents et magnets si souhaité. Le clic droit et l’envoi manuel restent indépendants de cet interrupteur.

L’adresse, le compte et le dossier restent modifiables dans les réglages. **Oublier ce compte** efface le compte et sa session du Trousseau pour le profil Safari courant.

## Sécurité et fonctionnement

Les pages web ne peuvent pas configurer le compte ou approuver un certificat. L’extension communique avec son module Swift par messagerie native. Les requêtes NAS passent par un moteur WebKit isolé avec stockage éphémère et scripts de page désactivés ; le certificat doit correspondre à l’empreinte approuvée. Les redirections NAS sont refusées. Le mot de passe est chiffré avec la clé RSA fournie par le NAS, sur HTTPS.

Le mot de passe, le jeton et les informations de connexion sont conservés dans le Trousseau, pas dans le stockage web ni ce dépôt. Le code temporaire est effacé après utilisation. Les cookies et identifiants des sites Safari ne sont jamais transmis au NAS. Pour certains torrents du même site, le petit fichier est récupéré en mémoire avec la session Safari, puis transmis au NAS sans sauvegarde locale ni SMB ; sa taille est limitée à 512 Kio.

La recherche automatique interroge volontairement `api.ugnas.com` : ce service voit l’adresse IP publique de la connexion, mais ne reçoit ni mot de passe ni jeton NAS. La saisie manuelle ne dépend pas de ce service.

Aucun nouvel ajout n’est tenté après une réponse ambiguë ou un délai dépassé. Une reconnexion et un nouvel essai ne sont permis qu’après un refus explicite d’authentification. **Une tâche acceptée par le NAS n’est pas une preuve que le téléchargement est terminé.**

## Limites

- Safari ne permet pas de remplacer universellement tous ses téléchargements. L’interception automatique couvre les liens et mécanismes torrent reconnus ; le clic droit et la saisie manuelle complètent ce fonctionnement.
- Un lien HTTP doit être accessible directement par le NAS. Les contenus protégés par la session du site, les URL expirées, les vidéos protégées et les fichiers ordinaires générés en `blob:` ou `data:` ne sont pas convertis en liens publics.
- Le suivi du menu attend environ 3,5 secondes après chaque réponse ; les notifications et corrections de noms sont vérifiées environ toutes les 30 secondes. Safari fermé, suspendu ou un Mac en veille peut retarder ces opérations.
- Les formats inconnus ne reçoivent pas d’extension inventée. Le renommage intervient après la fin du téléchargement ; le fichier réel est corrigé, tandis que l’historique de Téléchargements peut garder son nom initial.
- Les corrections restent limitées aux nouvelles tâches HTTP identifiées sans ambiguïté, sans remplacement forcé, avec 100 opérations en attente au maximum et une conservation de sept jours. Les listes sont limitées à 10 000 tâches par catégorie.
- Le réglage global macOS des icônes reste prioritaire : **Sombre → Automatique** permet de suivre le thème. L’icône statique de la liste des extensions Safari conserve sa version claire ; les logos du menu et des options suivent le thème.

## Développement et tests

```sh
node --test Tests/autonomous.test.cjs
bash Tests/run-native-tests.sh
```

Les tests JavaScript nécessitent Node.js ; les tests natifs nécessitent macOS, les outils Xcode, Python 3 et OpenSSL. Ils démarrent un serveur HTTPS local temporaire sur le port 18443 et n’utilisent aucun compte NAS réel. L’audit de la version 0.5.1 comprenait 45 tests JavaScript et 121 contrôles natifs. Voir [le rapport](AUDIT-0.5.1.md).

- `Extension/` : menu, réglages, scripts Safari et icônes.
- `Xcode/` : application AppKit, module Swift, authentification et transport NAS.
- `Design/Adaptive/UGREENIcon.icon/` : icône native avec apparences claire et sombre.
- `Design/generate-icons.swift` : génération des PNG et du logo adaptatif de la fenêtre.
- `Tests/` : tests de sécurité, validation des données et comportement.

## Références

- [Client communautaire ugnas-api](https://github.com/Fracizz/ugnas-api) : référence de protocole, sans code tiers chargé depuis une page NAS.
- [Intégration communautaire UGREEN](https://github.com/Tom-Bom-badil/home-assistant_ugreen-nas/blob/main/custom_components/ugreen/api.py) : référence pour la double authentification.
- [Documentation Apple Safari Web Extensions](https://developer.apple.com/documentation/safariservices/packaging-a-web-extension-for-safari).

Pour signaler un problème, ne joindre aucun mot de passe, code temporaire, jeton, URL signée, torrent privé ni export du Trousseau. Utiliser des données fictives dans les exemples.
