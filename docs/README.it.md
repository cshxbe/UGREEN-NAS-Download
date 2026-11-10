# UGREEN NAS Download

[English](../README.md) · [Français](README.fr.md) · [🌐 34](LANGUAGES.md)

Un'applicazione macOS e un'estensione Safari per inviare download all'applicazione **Download** di un NAS UGREEN sotto UGOS Pro, senza tenere aperta la pagina NAS.

Sorgenti e versione DMG: **0.6.1**. Progetto comunitario indipendente, non affiliato con UGREEN o Apple.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../Extension/icon-dark-128.png">
  <img src="../Extension/icon-128.png" width="96" height="96" alt="UGREEN NAS Download">
</picture>

L'interfaccia dell'app e dell'estensione è disponibile in 34 lingue.

## Caratteristiche

- Intercettazione dei collegamenti `.torrent` e `magnet:` sui siti autorizzati in Safari.
- Azione **Scarica su NAS** facendo clic con il pulsante destro del mouse su un collegamento, immagine, video o elemento audio direttamente accessibile.
- Invio manuale di uno URL dal menu dell'estensione.
- Account e sessione nel Portachiavi macOS; Supporto per l'autenticazione a due fattori e l'attendibilità del dispositivo.
- Ricerca opzionale per NAS tramite il servizio online UGREEN o indirizzo HTTPS manuale.
- Elenco dei download, avanzamento e velocità; notifiche facoltative di completamento, arresto e errore.
- Identificazione dei nomi e dei tipi di file HTTP, con correzione del nome dopo il download quando il file viene identificato in modo inequivocabile.
- Icone chiare e scure native e loghi Safari adattati al tema del sistema.

## Compatibilità

Il progetto è configurato per **macOS 27 o successivo** ed è stato compilato con **Xcode 27.1**, per Apple Silicon. I test NAS sono stati eseguiti con **DXP2800**, **UGOS Pro 1.20.0.0142** e **Download 1.19.1.0004**. Altre versioni non sono garantite: l'integrazione si basa su API osservate, senza un contratto pubblico UGREEN stabile.

## Installa da DMG

[Scarica UGREEN NAS Download 0.6.1 per Mac Apple Silicon](https://github.com/cshxbe/UGREEN-NAS-Download/releases/tag/v0.6.1).

1. Apri DMG, trascina **UGREEN NAS Download** in **Applicazioni**, quindi apri l'app.
2. In **Safari → Impostazioni → Avanzate**, abilita le funzionalità per gli sviluppatori web. In **Sviluppatore**, attiva **Consenti estensioni non firmate**, quindi attiva **UGREEN NAS Download** in **Estensioni**.
3. Configura NAS nelle impostazioni dell'interno.

Questo pacchetto pubblico è firmato localmente (ad hoc) e non autenticato. macOS potrebbe bloccarne l'apertura iniziale. Safari potrebbe chiedere di riattivare l'autorizzazione per le estensioni non firmate dopo essere usciti dal browser.

## Compila dal sorgente

1. Clona questo repository e apri `Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj`.
2. In **Firma e funzionalità**, scegli il tuo team Apple per i due obiettivi: l'applicazione e la sua estensione. Nessun team personale è inserito nel repository.
3. Scegli lo schema **UGREEN NAS Download**, destinazione **Il mio Mac**, quindi compila e avvia con Xcode.
4. Attiva l'estensione in **Safari → Impostazioni → Estensioni**, quindi autorizza i siti desiderati.
5. Apri le impostazioni dell'estensione e configura il tuo NAS come descritto di seguito.

Gli ID bundle di esempio sono `com.example.UGREENNASDownload` e `com.example.UGREENNASDownload.Extension`. Se hai bisogno di personalizzarli per la tua firma, modifica gli identificatori del progetto Xcode **e** le costanti corrispondenti in `Extension/background.js` e `ViewController.swift`: i valori devono rimanere coerenti.

Questa edizione pubblica utilizza identificatori e uno spazio Portachiavi separato dall'applicazione di sviluppo personale. Richiede la propria configurazione dello NAS. La firma di sviluppo non costituisce una distribuzione autenticata e l'attivazione potrebbe richiedere le impostazioni di sviluppo Safari appropriate per la tua firma.

Per verificare una compilazione senza firma, dalla root del repository:

```sh
xcodebuild \
  -project "Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj" \
  -scheme "UGREEN NAS Download" \
  -configuration Release -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO build
```

Questo controllo produce un'applicazione non firmata; usa il tuo team Apple per un'installazione di sviluppo utilizzabile in Safari. Mantieni l'albero del repository: i riferimenti da Xcode a `Extension` e `Design` sono relativi.

## Configura NAS

1. Inserisci l'indirizzo HTTPS dello NAS con la sua porta, il tuo identificatore e il percorso di destinazione assoluto sullo NAS. I campi personali sono vuoti per impostazione predefinita.
2. Fare clic su **Verifica certificato NAS**. Confronta l'impronta digitale SHA-256 con una fonte attendibile prima di confermare il certificato.
3. Inserisci la password e, se necessario, un doppio codice di autenticazione. Affidarsi al dispositivo è facoltativo; senza di esso, potrebbe essere richiesto un nuovo codice alla scadenza della sessione.
4. Fai clic su **Salva e verifica la connessione**. Consentire l'accesso alla rete locale quando richiesto da macOS.
5. Abilita l'intercettazione automatica di torrent e magneti, se lo desideri. Il clic con il tasto destro e l'invio manuale rimangono indipendenti da questo interruttore.

L'indirizzo, l'account e la cartella possono ancora essere modificati nelle impostazioni. **Dimenticare questo account** elimina l'account e la relativa sessione Portachiavi per il profilo Safari corrente.

## Sicurezza e funzionamento

Le pagine Web non possono configurare l'account o considerare attendibile un certificato. L'estensione comunica con il suo modulo Swift tramite messaggistica nativa. Le richieste NAS passano attraverso un motore WebKit isolato con archiviazione temporanea e scripting di pagina disabilitati; il certificato deve corrispondere all'impronta digitale approvata. I reindirizzamenti NAS vengono rifiutati. La password viene crittografata con la chiave RSA fornita da NAS, a HTTPS.

La password, il token e le informazioni di accesso vengono archiviati nel Portachiavi, non nell'archivio Web o in questo repository. Il codice temporaneo viene cancellato dopo l'uso. I cookie e gli identificatori dei siti Safari non vengono mai trasmessi a NAS. Per alcuni torrent dello stesso sito, il piccolo file viene recuperato in memoria con la sessione Safari, quindi trasmesso allo NAS senza salvataggio locale o SMB; la sua dimensione è limitata a 512 KiB.

La ricerca automatica interroga volontariamente `api.ugnas.com`: questo servizio vede l'indirizzo IP pubblico della connessione, ma non riceve né password né token NAS. L'inserimento manuale non dipende da questo servizio.

Non vengono tentate nuove aggiunte dopo una risposta ambigua o una scadenza è trascorsa. Una riconnessione ed un nuovo tentativo sono consentiti solo dopo un esplicito rifiuto di autenticazione. **Un'attività accettata da NAS non costituisce la prova che il download sia completo.**

## Limiti

- Safari non sostituisce universalmente tutti i suoi download. L'intercettazione automatica copre i collegamenti e i meccanismi torrent riconosciuti; il clic con il tasto destro e l'immissione manuale completano questa operazione.
- Un collegamento HTTP deve essere accessibile direttamente dallo NAS. I contenuti protetti della sessione del sito, URL scaduto, video protetti e file ordinari generati in `blob:` o `data:` non vengono convertiti in collegamenti pubblici.
- Il tracciamento del menu attende circa 3,5 secondi dopo ogni risposta; le notifiche e le correzioni dei nomi vengono controllate ogni 30 secondi circa. Safari chiuso, sospeso o un Mac in stop possono ritardare queste operazioni.
- I formati sconosciuti non ricevono un'estensione inventata. La ridenominazione avviene al termine del download; il file effettivo è fisso, mentre la cronologia dei download può mantenere il suo nome originale.
- Le correzioni rimangono limitate a nuove attività HTTP identificate in modo univoco, senza sostituzione forzata, con un massimo di 100 operazioni pendenti e una conservazione di sette giorni. Gli elenchi sono limitati a 10.000 attività per categoria.
- L'impostazione globale dell'icona macOS rimane prioritaria: **Scuro → Automatico** ti consente di seguire il tema. L'icona statica nell'elenco delle estensioni Safari rimane nella sua versione chiara; il menu e i loghi delle opzioni seguono il tema.

## Sviluppo e test

```sh
node --test Tests/autonomous.test.cjs
bash Tests/run-native-tests.sh
```

Il test JavaScript richiede Node.js; Il test nativo richiede gli strumenti macOS, Xcode, Python 3 e OpenSSL. Avviano un server HTTPS locale temporaneo sulla porta 18443 e non utilizzano alcun account NAS reale. L'audit 0.5.1 includeva 45 test JavaScript e 121 controlli nativi. Vedi [il rapporto](../AUDIT-0.5.1.md).

- `Extension/`: menu, impostazioni, script Safari e icone.
- `Xcode/`: applicazione AppKit, modulo Swift, autenticazione e trasporto NAS.
- `Design/Adaptive/UGREENIcon.icon/`: icona nativa con aspetti chiari e scuri.
- `Design/generate-icons.swift`: generazione di PNG e logo adattivo della finestra.
- `Tests/`: test di sicurezza, convalida dei dati e comportamento.

## Riferimenti

- [client della community ugnas-api](https://github.com/Fracizz/ugnas-api): riferimento al protocollo, senza codice di terze parti caricato da una pagina NAS.
- [Integrazione comunitaria UGREEN](https://github.com/Tom-Bom-badil/home-assistant_ugreen-nas/blob/main/custom_components/ugreen/api.py): riferimento per la doppia autenticazione.
- [Documentazione Apple Safari Estensioni web](https://developer.apple.com/documentation/safariservices/packaging-a-web-extension-for-safari).

Per segnalare un problema, non allegare password, codice temporaneo, token, firma URL, torrent privato o esportazione portachiavi. Utilizza dati fittizi negli esempi.
