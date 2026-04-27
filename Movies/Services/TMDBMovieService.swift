import TMDBKit

struct TMDBMovieService: MovieService {
    private let client: TMDBClient

    init(client: TMDBClient) {
        self.client = client
    }

    func fetchPopularMoviesPage(_ page: Int) async throws -> MoviePage {
        try await client.listMoviesPage(page: page)
    }
}
