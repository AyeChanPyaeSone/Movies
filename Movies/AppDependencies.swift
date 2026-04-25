import TMDBKit

enum AppDependencies {
    static let movieClient = TMDBClient(
        configuration: TMDBConfiguration(
            authorization: .placeholder
        )
    )
}
