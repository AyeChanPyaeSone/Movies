import Foundation

public enum TMDBError: Error, Sendable, LocalizedError, Equatable {
    case invalidRequest
    case missingAuthorization
    case invalidResponse
    case requestFailed(statusCode: Int, message: String?)

    public var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "The movie request could not be created."
        case .missingAuthorization:
            return "TMDB credentials are missing. Update the app configuration with your API key or bearer token."
        case .invalidResponse:
            return "The movie service returned an invalid response."
        case .requestFailed(let statusCode, let message):
            if let message, !message.isEmpty {
                return "TMDB request failed with status \(statusCode): \(message)"
            }

            return "TMDB request failed with status \(statusCode)."
        }
    }
}
