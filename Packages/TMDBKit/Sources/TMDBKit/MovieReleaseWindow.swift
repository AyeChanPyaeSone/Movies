import Foundation

public struct MovieReleaseWindow: Codable, Sendable, Equatable {
    public let maximum: String
    public let minimum: String

    public init(maximum: String, minimum: String) {
        self.maximum = maximum
        self.minimum = minimum
    }
}
