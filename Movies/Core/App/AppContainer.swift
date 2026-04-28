import Foundation
import TMDBKit

struct AppContainer {
    let movieService: any MovieService
}

extension AppContainer {
    static let live: AppContainer = {
        guard let bearerToken = AppConfiguration.tmdbBearerToken else {
            return AppContainer(movieService: MissingMovieService())
        }

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
