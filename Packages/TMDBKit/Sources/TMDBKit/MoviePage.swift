import Foundation

public struct MoviePage: Codable, Sendable, Equatable {
    public let page: Int
    public let results: [Movie]
    public let totalPages: Int
    public let totalResults: Int

    public init(page: Int, results: [Movie], totalPages: Int, totalResults: Int) {
        self.page = page
        self.results = results
        self.totalPages = totalPages
        self.totalResults = totalResults
    }
}
