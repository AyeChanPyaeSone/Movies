import TMDBKit

struct MissingMovieService: MovieService {
    func fetchMoviesPage(in category: MovieListCategory, page: Int) async throws -> MoviePage {
        throw TMDBError.missingAuthorization
    }

    func fetchMovieDetails(id: Int) async throws -> MovieDetails {
        throw TMDBError.missingAuthorization
    }
}
