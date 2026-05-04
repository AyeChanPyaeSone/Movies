import LoggingKit

enum MoviesLogger {
    static let app = PrefixedLogger(subsystem: "Movies", category: "app", prefix: "[App]")
    static let moviesList = PrefixedLogger(
        subsystem: "Movies",
        category: "moviesList",
        prefix: "[MoviesList]"
    )
    static let movieDetails = PrefixedLogger(
        subsystem: "Movies",
        category: "movieDetails",
        prefix: "[MovieDetails]"
    )
    static let moviesListSignposter = moviesList.signposter
    static let movieDetailsSignposter = movieDetails.signposter
}
