import Foundation
import Observation
import TMDBKit

@MainActor
@Observable
final class MoviesListViewModel {
    private(set) var movies: [Movie] = []
    private(set) var errorMessage: String?
    private(set) var currentPage = 0
    private(set) var totalPages = 0
    private var loadingState: LoadingState = .idle

    var isLoading: Bool {
        loadingState != .idle
    }

    var isLoadingMore: Bool {
        loadingState == .loadingNextPage
    }

    var canLoadMore: Bool {
        currentPage < totalPages
    }

    @ObservationIgnored
    private let movieClient: any MoviePageFetching

    init() {
        self.movieClient = AppDependencies.movieClient
    }

    init(movieClient: any MoviePageFetching) {
        self.movieClient = movieClient
    }

    func loadMovies(reset: Bool = true) async {
        guard !isLoading else {
            return
        }

        if !reset && !canLoadMore {
            return
        }

        let mode: LoadMode = reset ? .refresh : .nextPage
        let pageToLoad = reset ? 1 : currentPage + 1

        startLoading(mode)
        defer {
            loadingState = .idle
        }

        do {
            let moviePage = try await movieClient.fetchPopularMoviesPage(pageToLoad)
            apply(moviePage, for: mode)
        } catch {
            showError(error)
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

    private func showError(_ error: Error) {
        if let localizedError = error as? LocalizedError,
           let description = localizedError.errorDescription {
            errorMessage = description
        } else {
            errorMessage = error.localizedDescription
        }
    }
}

private extension MoviesListViewModel {
    enum LoadingState {
        case idle
        case loadingFirstPage
        case loadingNextPage
    }

    enum LoadMode {
        case refresh
        case nextPage
    }

    func startLoading(_ mode: LoadMode) {
        switch mode {
        case .refresh:
            loadingState = .loadingFirstPage
        case .nextPage:
            loadingState = .loadingNextPage
        }

        errorMessage = nil
    }

    func apply(_ moviePage: MoviePage, for mode: LoadMode) {
        switch mode {
        case .refresh:
            movies = moviePage.results
        case .nextPage:
            movies.append(contentsOf: moviePage.results)
        }

        currentPage = moviePage.page
        totalPages = moviePage.totalPages
    }
}
