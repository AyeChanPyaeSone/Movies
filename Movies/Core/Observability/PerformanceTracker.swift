import Sentry

enum PerformanceTracker {
    static func track<Value>(
        _ operation: PerformanceOperation,
        work: () async throws -> Value
    ) async throws -> Value {
        guard SentrySDK.isEnabled else {
            return try await work()
        }

        let span = makeSpan(for: operation)
        span.setTag(value: operation.featureTagValue, key: "feature")

        do {
            let value = try await work()
            span.finish(status: .ok)
            return value
        } catch {
            span.finish(status: status(for: error))
            throw error
        }
    }
}

enum PerformanceOperation {
    case moviesList(FeatureOperation)
    case movieDetails(FeatureOperation)

    enum FeatureOperation {
        case loadHomeShelves
        case loadNextPage
        case loadDetails
    }
}

private extension PerformanceTracker {
    static func makeSpan(for operation: PerformanceOperation) -> Span {
        if let currentSpan = SentrySDK.span {
            return currentSpan.startChild(
                operation: operation.spanOperation,
                description: operation.spanDescription
            )
        }

        return SentrySDK.startTransaction(
            name: operation.transactionName,
            operation: operation.spanOperation,
            bindToScope: false
        )
    }

    static func status(for error: any Error) -> SentrySpanStatus {
        if error is CancellationError {
            return .cancelled
        }

        return .internalError
    }
}

private extension PerformanceOperation {
    var featureTagValue: String {
        switch self {
        case .moviesList:
            "movies_list"
        case .movieDetails:
            "movie_details"
        }
    }

    var transactionName: String {
        switch self {
        case .moviesList:
            "Movies List"
        case .movieDetails:
            "Movie Details"
        }
    }

    var spanOperation: String {
        switch self {
        case .moviesList(let operation):
            "movies_list.\(operation.name)"
        case .movieDetails(let operation):
            "movie_details.\(operation.name)"
        }
    }

    var spanDescription: String {
        switch self {
        case .moviesList(let operation):
            operation.description
        case .movieDetails(let operation):
            operation.description
        }
    }
}

private extension PerformanceOperation.FeatureOperation {
    var name: String {
        switch self {
        case .loadHomeShelves:
            "load_home_shelves"
        case .loadNextPage:
            "load_next_page"
        case .loadDetails:
            "load_details"
        }
    }

    var description: String {
        switch self {
        case .loadHomeShelves:
            "Load home movie shelves"
        case .loadNextPage:
            "Load next movies page"
        case .loadDetails:
            "Load movie details"
        }
    }
}
