import Foundation

public struct MovieCastMember: Codable, Identifiable, Sendable, Equatable {
    public let id: Int
    public let name: String
    public let character: String?
    public let profilePath: String?
    public let order: Int?

    public init(
        id: Int,
        name: String,
        character: String?,
        profilePath: String?,
        order: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.character = character
        self.profilePath = profilePath
        self.order = order
    }
}
