import Foundation
import OSLog
import TMDBKit

struct AppContainer {
    let movieService: any MovieService
}

extension AppContainer {
    static let live: AppContainer = {
        guard let bearerToken = AppConfiguration.tmdbBearerToken else {
            MoviesLogger.app.error("[App] TMDB bearer token is missing. Falling back to MissingMovieService.")
            return AppContainer(movieService: MissingMovieService())
        }

        MoviesLogger.app.info("[App] Configured TMDB movie service from app configuration.")
        return AppContainer(
            movieService: TMDBMovieService(
                client: TMDBClient(
                    configuration: TMDBConfiguration(
                        authorization: .bearerToken(bearerToken)
                    )
                )
            )
        )
    }()
}

private enum AppConfiguration {
    static var tmdbBearerToken: String? {
        guard let infoDictionaryToken = Bundle.main.object(
            forInfoDictionaryKey: "TMDBBearerToken"
        ) as? String,
        !infoDictionaryToken.isEmpty else {
            return nil
        }

        return infoDictionaryToken
    }
}
