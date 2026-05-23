import Foundation

public enum MovieListCategory: String, Sendable, CaseIterable, Equatable, Hashable {
    case popular
    case topRated
    case upcoming
    case nowPlaying

    public var title: String {
        switch self {
        case .popular:
            "Popular"
        case .topRated:
            "Top Rated"
        case .upcoming:
            "Upcoming"
        case .nowPlaying:
            "Now Playing"
        }
    }

    var pathComponent: String {
        switch self {
        case .popular:
            "popular"
        case .topRated:
            "top_rated"
        case .upcoming:
            "upcoming"
        case .nowPlaying:
            "now_playing"
        }
    }

    var logName: String {
        switch self {
        case .popular:
            "popular"
        case .topRated:
            "top rated"
        case .upcoming:
            "upcoming"
        case .nowPlaying:
            "now playing"
        }
    }
}
