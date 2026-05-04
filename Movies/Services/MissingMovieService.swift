import TMDBKit

struct MissingMovieService: MovieService {
    func fetchPopularMoviesPage(_ page: Int) async throws -> MoviePage {
        throw TMDBError.missingAuthorization
    }

    func fetchMovieDetails(id: Int) async throws -> MovieDetails {
        throw TMDBError.missingAuthorization
    }
}
