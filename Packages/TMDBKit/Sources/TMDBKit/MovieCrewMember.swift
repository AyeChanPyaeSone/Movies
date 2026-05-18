import Foundation

public struct MovieCrewMember: Codable, Identifiable, Sendable, Equatable {
    public let id: Int
    public let name: String
    public let job: String
    public let department: String?
    public let profilePath: String?

    public init(
        id: Int,
        name: String,
        job: String,
        department: String?,
        profilePath: String?
    ) {
        self.id = id
        self.name = name
        self.job = job
        self.department = department
        self.profilePath = profilePath
    }
}
