import Foundation

public enum MovieListCategory: String, Sendable, CaseIterable, Equatable {
    case popular
    case topRated
    case upcoming
    case nowPlaying

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
