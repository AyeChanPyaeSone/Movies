import Foundation
import LoggingKit
import TMDBKit

struct AppContainer {
    let movieService: any MovieService
}

extension AppContainer {
    static let live: AppContainer = {
        guard let bearerToken = AppConfiguration.tmdbBearerToken else {
            MoviesLogger.app.error("TMDB bearer token is missing. Falling back to MissingMovieService.")
            return AppContainer(movieService: MissingMovieService())
        }

        MoviesLogger.app.info("Configured TMDB movie service from app configuration.")
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
