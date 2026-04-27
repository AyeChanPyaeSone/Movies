import TMDBKit

protocol MoviePageFetching: Sendable {
    func fetchPopularMoviesPage(_ page: Int) async throws -> MoviePage
}

extension TMDBClient: MoviePageFetching {
    func fetchPopularMoviesPage(_ page: Int) async throws -> MoviePage {
        try await listMoviesPage(page: page)
    }
}
// Agents.md
