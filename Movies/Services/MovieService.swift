import TMDBKit

protocol MovieService: Sendable {
    func listMovies() async throws -> [Movie]
}
