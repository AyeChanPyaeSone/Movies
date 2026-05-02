import OSLog

public struct PrefixedLogger: Sendable {
    public let signposter: OSSignposter

    private let logger: Logger
    private let prefix: String

    public init(subsystem: String, category: String, prefix: String) {
        let logger = Logger(subsystem: subsystem, category: category)

        self.logger = logger
        self.prefix = prefix
        self.signposter = OSSignposter(logger: logger)
    }

    public func log(_ level: OSLogType, _ message: @autoclosure () -> String) {
        let renderedMessage = message()
        logger.log(level: level, "\(prefix, privacy: .public) \(renderedMessage, privacy: .public)")
    }

    public func debug(_ message: @autoclosure () -> String) {
        log(.debug, message())
    }

    public func info(_ message: @autoclosure () -> String) {
        log(.info, message())
    }

    public func error(_ message: @autoclosure () -> String) {
        log(.error, message())
    }
}
