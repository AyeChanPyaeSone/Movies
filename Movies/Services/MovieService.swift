import TMDBKit

protocol MovieService: Sendable {
    func fetchMoviesPage(in category: MovieListCategory, page: Int) async throws -> MoviePage
}

extension MovieService {
    func fetchPopularMoviesPage(_ page: Int) async throws -> MoviePage {
        try await fetchMoviesPage(in: .popular, page: page)
    }

    func fetchTopRatedMoviesPage(_ page: Int) async throws -> MoviePage {
        try await fetchMoviesPage(in: .topRated, page: page)
    }

    func fetchUpcomingMoviesPage(_ page: Int) async throws -> MoviePage {
        try await fetchMoviesPage(in: .upcoming, page: page)
    }

    func fetchNowPlayingMoviesPage(_ page: Int) async throws -> MoviePage {
        try await fetchMoviesPage(in: .nowPlaying, page: page)
    }
}
