import Foundation

public struct TMDBConfiguration: Sendable, Equatable {
    public let authorization: TMDBAuthorization
    public let baseURL: URL
    public let defaultLanguage: String
    public let defaultRegion: String?

    public init(
        authorization: TMDBAuthorization,
        baseURL: URL = URL(string: "https://api.themoviedb.org/3")!,
        defaultLanguage: String = "en-US",
        defaultRegion: String? = nil
    ) {
        self.authorization = authorization
        self.baseURL = baseURL
        self.defaultLanguage = defaultLanguage
        self.defaultRegion = defaultRegion
    }
}
