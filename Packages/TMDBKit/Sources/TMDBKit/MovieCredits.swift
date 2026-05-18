import Foundation

public struct MovieCredits: Codable, Sendable, Equatable {
    public let cast: [MovieCastMember]
    public let crew: [MovieCrewMember]

    public init(cast: [MovieCastMember] = [], crew: [MovieCrewMember] = []) {
        self.cast = cast
        self.crew = crew
    }
}
