import TMDBKit

protocol MovieService: Sendable {
    func fetchPopularMoviesPage(_ page: Int) async throws -> MoviePage
    func fetchMovieDetails(id: Int) async throws -> MovieDetails
}
