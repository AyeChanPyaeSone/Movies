import LoggingKit

enum TMDBLogger {
    static let network = PrefixedLogger(
        subsystem: "TMDBKit",
        category: "network",
        prefix: "[TMDBKit]"
    )
}
