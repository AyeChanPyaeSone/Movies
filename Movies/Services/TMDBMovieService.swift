import TMDBKit

struct TMDBMovieService: MovieService {
    private let client: TMDBClient

    init(client: TMDBClient) {
        self.client = client
    }

    func fetchPopularMoviesPage(_ page: Int) async throws -> MoviePage {
        try await client.listMoviesPage(page: page)
    }

    func fetchMovieDetails(id: Int) async throws -> MovieDetails {
        try await client.movieDetails(id: id)
    }
}
