import Foundation
import Observation
import TMDBKit

@MainActor
@Observable
final class MoviesViewModel {
    typealias MoviePageLoader = @Sendable (Int) async throws -> MoviePage

    private(set) var movies: [Movie] = []
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var errorMessage: String?
    private(set) var currentPage = 0
    private(set) var totalPages = 0

    var canLoadMore: Bool {
        currentPage < totalPages
    }

    @ObservationIgnored
    private let moviePageLoader: MoviePageLoader

    init(moviePageLoader: @escaping MoviePageLoader = { page in
        try await AppDependencies.movieClient.listMoviesPage(page: page)
    }) {
        self.moviePageLoader = moviePageLoader
    }

    func loadMovies(reset: Bool = true) async {
        guard !isLoading else {
            return
        }

        guard reset || canLoadMore else {
            return
        }

        let pageToLoad = reset ? 1 : currentPage + 1
        isLoading = true
        isLoadingMore = !reset
        errorMessage = nil
        defer {
            isLoading = false
            isLoadingMore = false
        }

        do {
            let moviePage = try await moviePageLoader(pageToLoad)

            if reset {
                movies = moviePage.results
            } else {
                movies.append(contentsOf: moviePage.results)
            }

            currentPage = moviePage.page
            totalPages = moviePage.totalPages
        } catch {
            storeError(error)
        }
    }

    func loadNextPageIfNeeded(currentMovie: Movie) async {
        guard movies.last?.id == currentMovie.id else {
            return
        }

        await loadMovies(reset: false)
    }

    func dismissError() {
        errorMessage = nil
    }

    private func storeError(_ error: Error) {
        if let localizedError = error as? LocalizedError,
           let description = localizedError.errorDescription {
            errorMessage = description
        } else {
            errorMessage = error.localizedDescription
        }
    }
}
