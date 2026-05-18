import Foundation

public struct MovieDetails: Codable, Identifiable, Sendable, Equatable {
    public let id: Int
    public let title: String
    public let originalTitle: String?
    public let overview: String
    public let tagline: String?
    public let posterPath: String?
    public let backdropPath: String?
    public let releaseDate: String?
    public let runtime: Int?
    public let status: String?
    public let homepage: String?
    public let popularity: Double
    public let voteAverage: Double
    public let voteCount: Int
    public let genres: [MovieGenre]
    public let credits: MovieCredits?
    public let videos: MovieVideos?

    public init(
        id: Int,
        title: String,
        originalTitle: String? = nil,
        overview: String,
        tagline: String? = nil,
        posterPath: String?,
        backdropPath: String?,
        releaseDate: String?,
        runtime: Int?,
        status: String? = nil,
        homepage: String? = nil,
        popularity: Double,
        voteAverage: Double,
        voteCount: Int,
        genres: [MovieGenre] = [],
        credits: MovieCredits? = nil,
        videos: MovieVideos? = nil
    ) {
        self.id = id
        self.title = title
        self.originalTitle = originalTitle
        self.overview = overview
        self.tagline = tagline
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.releaseDate = releaseDate
        self.runtime = runtime
        self.status = status
        self.homepage = homepage
        self.popularity = popularity
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.genres = genres
        self.credits = credits
        self.videos = videos
    }
}
