import OSLog

enum MoviesLogger {
    static let app = Logger(subsystem: "Movies", category: "app")
    static let moviesList = Logger(subsystem: "Movies", category: "moviesList")
    static let moviesListSignposter = OSSignposter(logger: moviesList)
}
