import Foundation

public enum TMDBAuthorization: Sendable, Equatable {
    case apiKey(String)
    case bearerToken(String)
    case placeholder

    func apply(to components: inout URLComponents, headers: inout [String: String]) throws {
        switch self {
        case .apiKey(let apiKey):
            let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedKey.isEmpty else {
                throw TMDBError.missingAuthorization
            }

            var queryItems = components.queryItems ?? []
            queryItems.append(URLQueryItem(name: "api_key", value: trimmedKey))
            components.queryItems = queryItems

        case .bearerToken(let token):
            let trimmedToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedToken.isEmpty else {
                throw TMDBError.missingAuthorization
            }

            headers["Authorization"] = "Bearer \(trimmedToken)"

        case .placeholder:
            throw TMDBError.missingAuthorization
        }
    }
}
