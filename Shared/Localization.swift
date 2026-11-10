import Foundation

private let messages: [String: String] = {
    guard let resources = Bundle.main.resourceURL else { return [:] }
    for preferred in Locale.preferredLanguages + ["en"] {
        let components = Locale.components(fromIdentifier: preferred)
        guard let language = components[NSLocale.Key.languageCode.rawValue] else { continue }
        let traditional = components[NSLocale.Key.scriptCode.rawValue] == "Hant"
            || ["TW", "HK", "MO"].contains(components[NSLocale.Key.countryCode.rawValue] ?? "")
        let chinese = language == "zh" ? (traditional ? "zh_TW" : "zh_CN") : nil
        let candidates = [chinese, preferred.replacingOccurrences(of: "-", with: "_"), language].compactMap { $0 }
        for candidate in candidates {
            let url = resources.appendingPathComponent("_locales/\(candidate)/messages.json")
            if let data = try? Data(contentsOf: url),
               let table = try? JSONDecoder().decode([String: [String: String]].self, from: data) {
                return table.compactMapValues { $0["message"] }
            }
        }
    }
    return [:]
}()

func L(_ key: String, _ fallback: String) -> String {
    messages[key] ?? fallback
}

func L(_ key: String, _ fallback: String, _ value: Int) -> String {
    L(key, fallback).replacingOccurrences(of: "%d", with: String(value))
}
