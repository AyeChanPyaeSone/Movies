import Foundation

public struct MovieVideos: Codable, Sendable, Equatable {
    public let results: [MovieVideo]

    public init(results: [MovieVideo] = []) {
        self.results = results
    }
}
