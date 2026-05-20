import Sentry

enum ErrorReporter {
    static func capture(_ error: any Error, context: ErrorReportingContext) {
        SentrySDK.capture(error: error) { scope in
            scope.setTag(value: context.feature, key: "feature")
        }
    }
}

enum ErrorReportingContext {
    case moviesList
    case movieDetails
}

private extension ErrorReportingContext {
    var feature: String {
        switch self {
        case .moviesList:
            "movies_list"
        case .movieDetails:
            "movie_details"
        }
    }
}
