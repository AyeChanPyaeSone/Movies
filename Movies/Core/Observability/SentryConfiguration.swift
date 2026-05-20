import Sentry

enum SentryConfiguration {
    static func start() {
        guard let sentryDSN = AppConfiguration.sentryDSN else {
            return
        }

        SentrySDK.start { options in
            options.dsn = sentryDSN

            // https://docs.sentry.io/platforms/apple/data-management/data-collected/
            options.sendDefaultPii = true
            options.tracesSampleRate = 1.0
            
            options.sessionReplay.onErrorSampleRate = 1.0
            options.sessionReplay.sessionSampleRate = 1.0
            
            options.configureProfiling = {
                $0.sessionSampleRate = 1.0
                $0.lifecycle = .trace
            }

            options.attachViewHierarchy = true
            options.experimental.enableLogs = true
        }
    }
}
