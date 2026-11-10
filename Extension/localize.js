const uiLanguage = browser.i18n.getUILanguage().replaceAll("_", "-");
document.documentElement.lang = uiLanguage;
document.documentElement.dir = /^(ar|fa|he)(-|$)/i.test(uiLanguage) ? "rtl" : "ltr";
for (const node of document.querySelectorAll("[data-l10n]")) {
 const label = browser.i18n.getMessage(node.dataset.l10n);
 if (label) node.textContent = label;
}
for (const attribute of ["title", "placeholder", "aria-label"]) {
 for (const node of document.querySelectorAll(`[data-l10n-${attribute}]`)) {
  const label = browser.i18n.getMessage(node.getAttribute(`data-l10n-${attribute}`));
  if (label) node.setAttribute(attribute, label);
 }
}
