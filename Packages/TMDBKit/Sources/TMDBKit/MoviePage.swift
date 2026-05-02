import Foundation

public struct MoviePage: Codable, Sendable, Equatable {
    public let dates: MovieReleaseWindow?
    public let page: Int
    public let results: [Movie]
    public let totalPages: Int
    public let totalResults: Int

    public init(
        dates: MovieReleaseWindow? = nil,
        page: Int,
        results: [Movie],
        totalPages: Int,
        totalResults: Int
    ) {
        self.dates = dates
        self.page = page
        self.results = results
        self.totalPages = totalPages
        self.totalResults = totalResults
    }
}
