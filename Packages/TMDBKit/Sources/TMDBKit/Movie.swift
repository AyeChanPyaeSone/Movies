import Foundation

public struct Movie: Codable, Identifiable, Sendable, Equatable {
    public let id: Int
    public let title: String
    public let overview: String
    public let posterPath: String?
    public let backdropPath: String?
    public let releaseDate: String?
    public let popularity: Double
    public let voteAverage: Double
    public let voteCount: Int

    public init(
        id: Int,
        title: String,
        overview: String,
        posterPath: String?,
        backdropPath: String?,
        releaseDate: String?,
        popularity: Double,
        voteAverage: Double,
        voteCount: Int
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.releaseDate = releaseDate
        self.popularity = popularity
        self.voteAverage = voteAverage
        self.voteCount = voteCount
    }
}
