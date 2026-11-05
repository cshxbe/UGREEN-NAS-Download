# Audit du code — version 0.5.1

Date : 1 novembre 2026. Périmètre : tous les scripts Safari, gestion des messages et autorisations, interception et transfert des torrents, options et popup, client Swift, authentification et Trousseau, transport TLS, découverte, notifications, renommage, application AppKit, configuration Xcode et ressources. Revue statique et tests locaux ; pas de nouvel essai complet sur tous les sites ou avec le NAS réel pour cette version.

## Problèmes corrigés

- **Identification des médias** : la présence d’un conteneur `ftyp` ne suffit plus à conclure MP4. Reconnaissance des variantes audio M4A/M4B, M4V, 3GP/3G2 ; conservation des types spécifiques et absence de supposition pour une marque inconnue ou HEIF générique.
- **Arrêt du processus natif** : conversion contrôlée de l’état numérique fourni par le NAS. Une valeur immense, infinie ou fractionnaire ne provoque plus de conversion Swift fatale.
- **Pagination** : le suivi des notifications lit aussi les fichiers terminés après la première page de 50. Une page pleine sans total ne signifie plus que la liste est terminée. Les totaux numériques et textuels sont pris en charge, avec une limite de 10 000 éléments par liste.
- **Renommage silencieusement abandonné** : les informations de nom incomplètes restent en attente et produisent un message d’erreur ; elles ne sont plus simplement retirées de la file.
- **Notifications** : si le module natif refuse ou ne confirme pas la désactivation, le réglage web reste actif et l’erreur remonte aux options.
- **NAS lent** : les alarmes identiques sont regroupées pendant une requête en attente, pour éviter l’accumulation de demandes de surveillance.
- **Protocoles des liens** : reconnaissance insensible à la casse, notamment `MAGNET:` et `HTTPS:`.
- **Site bloqué** : délai maximal de 20 secondes pour la récupération en mémoire d’un torrent ; le blocage est libéré pour un nouvel essai.
- **Ancienne ressource d’accueil** : suppression d’un texte périmé demandant de garder une page NAS ouverte. L’interface native actuelle ne dépend pas de cette ressource.

## Vérifications

- 45 tests JavaScript réussis, dont refus de désactivation, absence de confirmation, regroupement d’alarmes et expiration d’un site torrent.
- 121 tests Swift réussis : signatures et noms de fichiers, pagination et valeurs extrêmes, validation des liens, import torrent, découverte, événements de téléchargement, transport binaire, certificat accepté/refusé et redirections refusées avec un serveur local éphémère.
- Vérification de la syntaxe de tous les scripts JavaScript et des fichiers plist.
- Compilation Release macOS et signature contrôlées. Avertissement externe Xcode relatif au simulateur iOS obsolète, sans incidence sur la cible macOS.

## Limites qui subsistent

Une revue et des tests ne garantissent pas l’absence de tout bug. Les liens nécessitant la session du site ne deviennent pas automatiquement accessibles au NAS ; les flux protégés et fichiers générés restent soumis aux limites Safari. L’identification d’un format inconnu reste incertaine. Le renommage corrige le fichier réel après sa fin, pas le nom historique de la tâche dans Téléchargements ; Safari doit être ouvert, sinon l’opération reprend à sa réouverture. Les renommages restent limités aux nouvelles tâches HTTP identifiées sans ambiguïté, sans remplacement forcé, avec une conservation maximale de 7 jours et 100 opérations en attente. Au-delà de ces limites, une vérification manuelle est nécessaire.

La copie publique utilise des identifiants de bundle d’exemple et ne contient pas d’équipe de signature personnelle.
