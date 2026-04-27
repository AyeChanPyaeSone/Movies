import Foundation
import Testing
import TMDBKit
@testable import Movies

struct MoviesTests {
    @Test
    @MainActor
    func loadMoviesStoresFetchedMovies() async {
        let movie = Movie(
            id: 101,
            title: "Architecture Matters",
            overview: "A team refactors a small app before complexity wins.",
            posterPath: nil,
            backdropPath: nil,
            releaseDate: "2026-04-27",
            popularity: 10,
            voteAverage: 9,
            voteCount: 42
        )
        let viewModel = MoviesListViewModel(
            movieService: MockMovieService(result: .success([movie]))
        )

        await viewModel.loadMovies()

        #expect(viewModel.movies == [movie])
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }

    @Test
    @MainActor
    func loadMoviesStoresLocalizedErrorsAndClearsMovies() async {
        let viewModel = MoviesListViewModel(
            movieService: MockMovieService(
                result: .failure(MockError(description: "The test service failed."))
            )
        )

        await viewModel.loadMovies()

        #expect(viewModel.movies.isEmpty)
        #expect(viewModel.errorMessage == "The test service failed.")
        #expect(viewModel.isLoading == false)
    }
}

private struct MockMovieService: MovieService {
    let result: Result<[Movie], Error>

    func listMovies() async throws -> [Movie] {
        try result.get()
    }
}

private struct MockError: LocalizedError {
    let description: String

    var errorDescription: String? {
        description
    }
}
