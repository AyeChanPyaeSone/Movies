import TMDBKit

protocol MovieService: Sendable {
    func fetchPopularMoviesPage(_ page: Int) async throws -> MoviePage
}
