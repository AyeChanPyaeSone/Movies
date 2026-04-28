import Foundation
import Observation
import OSLog
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
    private let movieService: any MovieService
    @ObservationIgnored
    private let logger: Logger
    @ObservationIgnored
    private let signposter: OSSignposter

    init(
        movieService: any MovieService,
        logger: Logger? = nil,
        signposter: OSSignposter? = nil
    ) {
        self.movieService = movieService
        self.logger = logger ?? MoviesLogger.moviesList
        self.signposter = signposter ?? MoviesLogger.moviesListSignposter
    }

    func loadMovies(reset: Bool = true) async {
        guard !isLoading else {
            logger.debug("Skipped movie load because another request is already in flight.")
            return
        }

        if !reset && !canLoadMore {
            logger.debug(
                "Skipped next-page load because pagination is exhausted at page \(self.currentPage, privacy: .public) of \(self.totalPages, privacy: .public)."
            )
            return
        }

        let mode: LoadMode = reset ? .refresh : .nextPage
        let pageToLoad = reset ? 1 : currentPage + 1
        let intervalState = signposter.beginInterval(
            "Load Movies",
            id: signposter.makeSignpostID(),
            "\(mode.logLabel, privacy: .public) page \(pageToLoad, privacy: .public)"
        )

        startLoading(mode)
        defer {
            signposter.endInterval("Load Movies", intervalState)
            loadingState = .idle
        }

        do {
            logger.info(
                "Starting \(mode.logLabel, privacy: .public) movie load for page \(pageToLoad, privacy: .public)."
            )
            let moviePage = try await movieService.fetchPopularMoviesPage(pageToLoad)
            apply(moviePage, for: mode)
            logger.info(
                "Loaded page \(moviePage.page, privacy: .public) with \(moviePage.results.count, privacy: .public) movies. Current list count: \(self.movies.count, privacy: .public)."
            )
        } catch {
            logger.error(
                "Movie load failed for page \(pageToLoad, privacy: .public): \(String(describing: error), privacy: .public)"
            )
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

        var logLabel: String {
            switch self {
            case .refresh:
                "refresh"
            case .nextPage:
                "next-page"
            }
        }
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

    func showError(_ error: Error) {
        if let localizedError = error as? LocalizedError,
           let description = localizedError.errorDescription {
            errorMessage = description
        } else {
            errorMessage = error.localizedDescription
        }
    }
}
