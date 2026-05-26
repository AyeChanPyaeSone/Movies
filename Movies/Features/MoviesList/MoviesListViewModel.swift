import Foundation
import LoggingKit
import Observation
import OSLog
import TMDBKit

@MainActor
@Observable
final class MoviesListViewModel {
    private(set) var errorMessage: String?
    var searchText = ""
    private var loadingState: LoadingState = .idle
    private var moviePagesByCategory: [MovieListCategory: MoviePage] = [:]

    var movies: [Movie] {
        uniqueMovies(
            from: displayCategories.flatMap { category in
                moviePagesByCategory[category]?.results ?? []
            }
        )
    }

    var isLoading: Bool {
        switch loadingState {
        case .idle:
            false
        case .loadingHome, .loadingNextPage:
            true
        }
    }

    var isLoadingMore: Bool {
        if case .loadingNextPage = loadingState {
            return true
        }

        return false
    }

    var featuredMovie: Movie? {
        guard searchText.isEmpty else {
            return nil
        }

        return moviePagesByCategory[.nowPlaying]?.results.first
    }

    var visibleSections: [MoviesListSection] {
        if !searchText.isEmpty {
            let results = filteredMovies
            guard !results.isEmpty else {
                return []
            }

            return [MoviesListSection(title: "Results", movies: results, category: nil)]
        }

        return displayCategories.compactMap(makeSection(for:))
    }

    @ObservationIgnored
    let movieService: any MovieService
    @ObservationIgnored
    private let signposter: OSSignposter

    private let displayCategories: [MovieListCategory] = [
        .topRated,
        .upcoming,
        .nowPlaying,
    ]

    init(
        movieService: any MovieService,
        signposter: OSSignposter? = nil
    ) {
        self.movieService = movieService
        self.signposter = signposter ?? MoviesLogger.moviesListSignposter
    }

    func loadMovies(reset: Bool = true) async {
        guard !isLoading else {
            MoviesLogger.moviesList.debug("Skipped movie load because another request is already in flight.")
            return
        }

        let intervalState: OSSignpostIntervalState
        if reset {
            intervalState = signposter.beginInterval(
                "Load Movies",
                id: signposter.makeSignpostID(),
                "refresh home shelves"
            )
        } else {
            intervalState = signposter.beginInterval(
                "Load Movies",
                id: signposter.makeSignpostID(),
                "reload home shelves"
            )
        }

        loadingState = .loadingHome
        errorMessage = nil

        defer {
            signposter.endInterval("Load Movies", intervalState)
            loadingState = .idle
        }

        do {
            MoviesLogger.moviesList.info("Loading home movie shelves.")
            let loadedPages = try await PerformanceTracker.track(
                .moviesList(.loadHomeShelves)
            ) {
                try await fetchHomePages()
            }
            applyHomePages(loadedPages)
            MoviesLogger.moviesList.info(
                "Loaded home shelves: top rated \(loadedPages[.topRated]?.results.count ?? 0), upcoming \(loadedPages[.upcoming]?.results.count ?? 0), now playing \(loadedPages[.nowPlaying]?.results.count ?? 0)."
            )
        } catch {
            MoviesLogger.moviesList.error(
                "Home movie shelf load failed: \(String(describing: error))"
            )
            ErrorReporter.capture(
                error,
                context: .moviesList
            )
            showError(error)
        }
    }

    func loadNextPageIfNeeded(
        in section: MoviesListSection,
        currentMovie: Movie,
        source: MoviePaginationSource = .homeShelf
    ) async {
        guard searchText.isEmpty else {
            return
        }

        guard let category = section.category else {
            return
        }

        guard let displayedMovies = makeSection(for: category)?.movies,
              displayedMovies.last?.id == currentMovie.id else {
            return
        }

        guard let currentPage = moviePagesByCategory[category] else {
            return
        }

        guard currentPage.page < currentPage.totalPages else {
            MoviesLogger.moviesList.debug(
                "Skipped next-page load for \(category.title) from \(source.logName) because pagination is exhausted at page \(currentPage.page) of \(currentPage.totalPages)."
            )
            return
        }

        guard !isLoading else {
            MoviesLogger.moviesList.debug(
                "Skipped next-page load for \(category.title) from \(source.logName) because another request is already in flight."
            )
            return
        }

        let nextPage = currentPage.page + 1
        let intervalState = signposter.beginInterval(
            "Load Movies",
            id: signposter.makeSignpostID(),
            "next page \(nextPage) for \(category.title)"
        )

        loadingState = .loadingNextPage(category)
        errorMessage = nil

        defer {
            signposter.endInterval("Load Movies", intervalState)
            loadingState = .idle
        }

        do {
            MoviesLogger.moviesList.info(
                "Loading page \(nextPage) for \(category.title) from \(source.logName)."
            )
            let moviePage = try await PerformanceTracker.track(
                .moviesList(.loadNextPage),
                tags: [
                    "category": category.metricName,
                    "page": nextPage.formatted(.number.grouping(.never)),
                    "source": source.rawValue,
                ]
            ) {
                try await fetchMoviesPage(in: category, page: nextPage)
            }
            append(moviePage, to: category)
            MoviesLogger.moviesList.info(
                "Loaded page \(moviePage.page) for \(category.title) from \(source.logName) with \(moviePage.results.count) movies."
            )
        } catch {
            MoviesLogger.moviesList.error(
                "Movie load failed for \(category.title) page \(nextPage) from \(source.logName): \(String(describing: error))"
            )
            ErrorReporter.capture(
                error,
                context: .moviesList
            )
            showError(error)
        }
    }

    func dismissError() {
        errorMessage = nil
    }

    func categorySection(for category: MovieListCategory) -> MoviesListSection? {
        guard let moviePage = moviePagesByCategory[category],
              !moviePage.results.isEmpty else {
            return nil
        }

        return MoviesListSection(
            title: category.title,
            movies: moviePage.results,
            category: category
        )
    }
}

enum MoviePaginationSource: String {
    case homeShelf = "home_shelf"
    case categoryScreen = "category_screen"

    var logName: String {
        switch self {
        case .homeShelf:
            "home shelf"
        case .categoryScreen:
            "category screen"
        }
    }
}

extension MovieListCategory {
    var metricName: String {
        switch self {
        case .popular:
            "popular"
        case .topRated:
            "top_rated"
        case .upcoming:
            "upcoming"
        case .nowPlaying:
            "now_playing"
        }
    }
}

private extension MoviesListViewModel {
    enum LoadingState {
        case idle
        case loadingHome
        case loadingNextPage(MovieListCategory)
    }

    var filteredMovies: [Movie] {
        movies.filter { movie in
            movie.title.localizedStandardContains(searchText)
        }
    }

    func fetchHomePages() async throws -> [MovieListCategory: MoviePage] {
        async let topRatedPage = fetchMoviesPage(in: .topRated, page: 1)
        async let upcomingPage = fetchMoviesPage(in: .upcoming, page: 1)
        async let nowPlayingPage = fetchMoviesPage(in: .nowPlaying, page: 1)

        return [
            .topRated: try await topRatedPage,
            .upcoming: try await upcomingPage,
            .nowPlaying: try await nowPlayingPage,
        ]
    }

    func fetchMoviesPage(in category: MovieListCategory, page: Int) async throws -> MoviePage {
        switch category {
        case .popular:
            try await movieService.fetchPopularMoviesPage(page)
        case .topRated:
            try await movieService.fetchTopRatedMoviesPage(page)
        case .upcoming:
            try await movieService.fetchUpcomingMoviesPage(page)
        case .nowPlaying:
            try await movieService.fetchNowPlayingMoviesPage(page)
        }
    }

    func makeSection(for category: MovieListCategory) -> MoviesListSection? {
        guard let moviePage = moviePagesByCategory[category] else {
            return nil
        }

        let movies: [Movie]
        switch category {
        case .nowPlaying:
            movies = Array(moviePage.results.dropFirst())
        case .popular, .topRated, .upcoming:
            movies = moviePage.results
        }

        guard !movies.isEmpty else {
            return nil
        }

        return MoviesListSection(
            title: category.title,
            movies: movies,
            category: category
        )
    }

    func uniqueMovies(from movies: [Movie]) -> [Movie] {
        var seenMovieIDs = Set<Int>()

        return movies.filter { movie in
            seenMovieIDs.insert(movie.id).inserted
        }
    }

    func applyHomePages(_ loadedPages: [MovieListCategory: MoviePage]) {
        moviePagesByCategory = loadedPages
    }

    func append(_ moviePage: MoviePage, to category: MovieListCategory) {
        guard let currentPage = moviePagesByCategory[category] else {
            moviePagesByCategory[category] = moviePage
            return
        }

        moviePagesByCategory[category] = MoviePage(
            dates: moviePage.dates ?? currentPage.dates,
            page: moviePage.page,
            results: currentPage.results + moviePage.results,
            totalPages: moviePage.totalPages,
            totalResults: moviePage.totalResults
        )
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
