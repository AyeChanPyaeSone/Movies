import Foundation

public struct MovieVideo: Codable, Identifiable, Sendable, Equatable {
    public let id: String
    public let key: String
    public let name: String
    public let site: String
    public let type: String
    public let official: Bool?
    public let publishedAt: String?
    public let size: Int?

    public init(
        id: String,
        key: String,
        name: String,
        site: String,
        type: String,
        official: Bool? = nil,
        publishedAt: String? = nil,
        size: Int? = nil
    ) {
        self.id = id
        self.key = key
        self.name = name
        self.site = site
        self.type = type
        self.official = official
        self.publishedAt = publishedAt
        self.size = size
    }
}
