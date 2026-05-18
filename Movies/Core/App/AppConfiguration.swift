import Foundation

enum AppConfiguration {
    static var tmdbBearerToken: String? {
        string(forInfoDictionaryKey: "TMDBBearerToken")
    }

    static var sentryDSN: String? {
        guard let hostPath = string(forInfoDictionaryKey: "SentryDSNHostPath") else {
            return nil
        }

        return "https://\(hostPath)"
    }

    private static func string(forInfoDictionaryKey key: String) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
              !value.isEmpty else {
            return nil
        }

        return value
    }
}
