import TMDBKit

struct TMDBMovieService: MovieService {
    private let client: TMDBClient

    init(client: TMDBClient) {
        self.client = client
    }

    func listMovies() async throws -> [Movie] {
        try await client.listMovies()
    }
}
