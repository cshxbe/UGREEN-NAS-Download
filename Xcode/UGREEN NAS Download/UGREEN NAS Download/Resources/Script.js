function show(enabled, useSettingsInsteadOfPreferences) {
    document.querySelector('.state-on').innerText="L’extension est activée dans Safari.";
    document.querySelector('.state-off').innerText="Activez l’extension dans Safari → Réglages → Extensions.";
    document.querySelector('.state-unknown').innerText="Ouvrez les réglages Safari pour vérifier l’extension.";
    document.querySelector('.open-preferences').innerText="Ouvrir les réglages de l’extension…";

    if (typeof enabled === "boolean") {
        document.body.classList.toggle(`state-on`, enabled);
        document.body.classList.toggle(`state-off`, !enabled);
    } else {
        document.body.classList.remove(`state-on`);
        document.body.classList.remove(`state-off`);
    }
}

function openPreferences() {
    webkit.messageHandlers.controller.postMessage("open-preferences");
}

document.querySelector("button.open-preferences").addEventListener("click", openPreferences);

document.getElementById("network-permission").addEventListener("click",()=>webkit.messageHandlers.controller.postMessage("network-permission"));
