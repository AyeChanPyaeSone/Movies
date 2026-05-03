import TMDBKit

struct TMDBMovieService: MovieService {
    private let client: TMDBClient

    init(client: TMDBClient) {
        self.client = client
    }

    func fetchMoviesPage(in category: MovieListCategory, page: Int) async throws -> MoviePage {
        try await client.listMoviesPage(in: category, page: page)
    }
}
