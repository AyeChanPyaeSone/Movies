import Foundation
import Testing
import TMDBKit
@testable import Movies

struct MoviesTests {
    @MainActor
    @Test("Initial load stores page results and pagination metadata")
    func initialLoadStoresResultsAndMetadata() async {
        let harness = MoviesListHarness()
        let firstPage = makePage(page: 1, totalPages: 3, ids: [1, 2])

        await harness.setPage(firstPage, for: 1)
        await harness.loadFirstPage()

        #expect(harness.viewModel.movies == firstPage.results)
        #expect(harness.viewModel.currentPage == 1)
        #expect(harness.viewModel.totalPages == 3)
        #expect(harness.viewModel.canLoadMore)
        #expect(harness.viewModel.errorMessage == nil)
        #expect(await harness.requestedPages() == [1])
    }

    @MainActor
    @Test("Loading the last visible movie appends the next page once")
    func reachingLastMovieAppendsNextPage() async throws {
        let harness = MoviesListHarness()
        let firstPage = makePage(page: 1, totalPages: 3, ids: [1, 2])
        let secondPage = makePage(page: 2, totalPages: 3, ids: [3])

        await harness.setPage(firstPage, for: 1)
        await harness.setPage(secondPage, for: 2)

        await harness.loadFirstPage()
        try await harness.loadNextPage()

        #expect(harness.viewModel.movies == firstPage.results + secondPage.results)
        #expect(harness.viewModel.currentPage == 2)
        #expect(harness.viewModel.totalPages == 3)
        #expect(harness.viewModel.canLoadMore)
        #expect(await harness.requestedPages() == [1, 2])
    }

    @MainActor
    @Test("Pagination is ignored while a load is already in flight")
    func noAppendOccursWhileLoading() async throws {
        let harness = MoviesListHarness()
        let gate = LoadGate()
        let firstPage = makePage(page: 1, totalPages: 3, ids: [1])
        let secondPage = makePage(page: 2, totalPages: 3, ids: [2])

        await harness.setPage(firstPage, for: 1)
        await harness.setGatedPage(secondPage, for: 2, gate: gate)

        await harness.loadFirstPage()
        let pendingLoad = try harness.startLoadingNextPage()

        await harness.waitForRequestedPageCount(2)

        #expect(harness.viewModel.isLoading)
        #expect(harness.viewModel.isLoadingMore)

        try await harness.loadNextPage()
        await gate.open()
        await pendingLoad.value

        #expect(harness.viewModel.movies == firstPage.results + secondPage.results)
        #expect(harness.viewModel.currentPage == 2)
        #expect(harness.viewModel.totalPages == 3)
        #expect(harness.viewModel.canLoadMore)
        #expect(await harness.requestedPages() == [1, 2])
    }

    @MainActor
    @Test("Pagination stops at the final page")
    func noAppendOccursOnFinalPage() async throws {
        let harness = MoviesListHarness()
        let firstPage = makePage(page: 1, totalPages: 1, ids: [1])

        await harness.setPage(firstPage, for: 1)
        await harness.loadFirstPage()
        try await harness.loadNextPage()

        #expect(harness.viewModel.movies == firstPage.results)
        #expect(harness.viewModel.currentPage == 1)
        #expect(harness.viewModel.totalPages == 1)
        #expect(harness.viewModel.canLoadMore == false)
        #expect(await harness.requestedPages() == [1])
    }

    @MainActor
    @Test("Append failures preserve existing movies and page state")
    func appendFailureKeepsExistingMovies() async throws {
        let harness = MoviesListHarness()
        let firstPage = makePage(page: 1, totalPages: 2, ids: [1])

        await harness.setPage(firstPage, for: 1)
        await harness.setFailure("Next page failed", for: 2)

        await harness.loadFirstPage()
        try await harness.loadNextPage()

        #expect(harness.viewModel.movies == firstPage.results)
        #expect(harness.viewModel.currentPage == 1)
        #expect(harness.viewModel.totalPages == 2)
        #expect(harness.viewModel.canLoadMore)
        #expect(harness.viewModel.errorMessage == "Next page failed")
        #expect(await harness.requestedPages() == [1, 2])
    }

    @MainActor
    @Test("Refresh failures keep the current movies visible")
    func resetFailureKeepsExistingMovies() async {
        let harness = MoviesListHarness()
        let firstPage = makePage(page: 1, totalPages: 3, ids: [1, 2])

        await harness.setPage(firstPage, for: 1)
        await harness.loadFirstPage()
        await harness.setFailure("Refresh failed", for: 1)
        await harness.refresh()

        #expect(harness.viewModel.movies == firstPage.results)
        #expect(harness.viewModel.currentPage == 1)
        #expect(harness.viewModel.totalPages == 3)
        #expect(harness.viewModel.canLoadMore)
        #expect(harness.viewModel.errorMessage == "Refresh failed")
        #expect(await harness.requestedPages() == [1, 1])
    }

    @MainActor
    @Test("Search filters titles using localized matching and switches to results mode")
    func searchFiltersTitles() async {
        let harness = MoviesListHarness()
        let page = MoviePage(
            page: 1,
            results: [
                makeMovie(id: 1, title: "Stellar Odyssey"),
                makeMovie(id: 2, title: "Comedy Night"),
                makeMovie(id: 3, title: "Galactic Run")
            ],
            totalPages: 1,
            totalResults: 3
        )

        await harness.setPage(page, for: 1)
        await harness.loadFirstPage()
        harness.viewModel.searchText = "stellar"

        #expect(harness.viewModel.featuredMovie == nil)
        #expect(harness.viewModel.visibleSections == [
            MoviesListSection(title: "Results", movies: [makeMovie(id: 1, title: "Stellar Odyssey")])
        ])
    }

    @MainActor
    @Test("Discover mode promotes the first movie and sections the rest")
    func discoverModePromotesFirstMovie() async {
        let harness = MoviesListHarness()
        let page = MoviePage(
            page: 1,
            results: [
                makeMovie(id: 1, title: "Stellar Odyssey"),
                makeMovie(id: 2, title: "Comedy Night"),
                makeMovie(id: 3, title: "Galactic Run"),
                makeMovie(id: 4, title: "Velvet Heist"),
                makeMovie(id: 5, title: "Afterlight")
            ],
            totalPages: 1,
            totalResults: 5
        )

        await harness.setPage(page, for: 1)
        await harness.loadFirstPage()

        let sections = harness.viewModel.visibleSections

        #expect(harness.viewModel.featuredMovie == page.results.first)
        #expect(sections.map(\.title) == ["Action", "Comedy"])
        #expect(sections.flatMap(\.movies) == Array(page.results.dropFirst()))
    }

    @MainActor
    @Test("Movie details load stores rich TMDB details")
    func movieDetailsLoadStoresRichDetails() async {
        let harness = MovieDetailsHarness()
        let details = makeDetails(id: 1)

        await harness.setDetails(details, for: 1)
        await harness.loadDetails()

        #expect(harness.viewModel.details == details)
        #expect(harness.viewModel.title == details.title)
        #expect(harness.viewModel.cast.map(\.name) == ["Maya Chen", "Jon Bell"])
        #expect(harness.viewModel.directors.map(\.name) == ["Rae Coleman"])
        #expect(harness.viewModel.trailerURL?.absoluteString == "https://www.youtube.com/watch?v=abc123")
        #expect(harness.viewModel.errorMessage == nil)
        #expect(await harness.requestedDetailIDs() == [1])
    }

    @MainActor
    @Test("Movie details failure keeps initial list data visible")
    func movieDetailsFailureKeepsInitialMovieData() async {
        let initialMovie = makeMovie(id: 1, title: "Initial Title")
        let harness = MovieDetailsHarness(initialMovie: initialMovie)

        await harness.setDetailsFailure("Details failed", for: 1)
        await harness.loadDetails()

        #expect(harness.viewModel.details == nil)
        #expect(harness.viewModel.title == "Initial Title")
        #expect(harness.viewModel.overview == initialMovie.overview)
        #expect(harness.viewModel.errorMessage == "Details failed")
        #expect(await harness.requestedDetailIDs() == [1])
    }
}

@MainActor
private struct MoviesListHarness {
    let movieService: MockMovieService
    let viewModel: MoviesListViewModel

    init() {
        let movieService = MockMovieService()
        self.movieService = movieService
        self.viewModel = MoviesListViewModel(movieService: movieService)
    }

    func setPage(_ moviePage: MoviePage, for page: Int) async {
        await movieService.setResponse(.success(moviePage), for: page)
    }

    func setGatedPage(_ moviePage: MoviePage, for page: Int, gate: LoadGate) async {
        await movieService.setResponse(.gatedSuccess(moviePage, gate), for: page)
    }

    func setFailure(_ message: String, for page: Int) async {
        await movieService.setResponse(.failure(TestError(message)), for: page)
    }

    func loadFirstPage() async {
        await viewModel.loadMovies()
    }

    func refresh() async {
        await viewModel.loadMovies(reset: true)
    }

    func loadNextPage() async throws {
        let lastMovie = try #require(viewModel.movies.last)
        await viewModel.loadNextPageIfNeeded(currentMovie: lastMovie)
    }

    func startLoadingNextPage() throws -> Task<Void, Never> {
        let lastMovie = try #require(viewModel.movies.last)
        return Task {
            await viewModel.loadNextPageIfNeeded(currentMovie: lastMovie)
        }
    }

    func waitForRequestedPageCount(_ expectedCount: Int) async {
        await waitUntil {
            await movieService.requestedPages().count == expectedCount
        }
    }

    func requestedPages() async -> [Int] {
        await movieService.requestedPages()
    }
}

private actor MockMovieService: MovieService {
    private var pages: [Int] = []
    private var responses: [Int: MockResponse] = [:]
    private var detailIDs: [Int] = []
    private var detailResponses: [Int: Result<MovieDetails, TestError>] = [:]

    func setResponse(_ response: MockResponse, for page: Int) {
        responses[page] = response
    }

    func requestedPages() -> [Int] {
        pages
    }

    func setDetailsResponse(_ response: Result<MovieDetails, TestError>, for id: Int) {
        detailResponses[id] = response
    }

    func requestedDetailIDs() -> [Int] {
        detailIDs
    }

    func fetchPopularMoviesPage(_ page: Int) async throws -> MoviePage {
        pages.append(page)

        guard let response = responses[page] else {
            throw TestError("Unexpected page requested: \(page)")
        }

        switch response {
        case .success(let moviePage):
            return moviePage
        case .failure(let error):
            throw error
        case .gatedSuccess(let moviePage, let gate):
            await gate.wait()
            return moviePage
        }
    }

    func fetchMovieDetails(id: Int) async throws -> MovieDetails {
        detailIDs.append(id)

        guard let response = detailResponses[id] else {
            throw TestError("Unexpected details requested: \(id)")
        }

        return try response.get()
    }
}

@MainActor
private struct MovieDetailsHarness {
    let movieService: MockMovieService
    let viewModel: MovieDetailsViewModel

    init(initialMovie: Movie? = makeMovie(id: 1)) {
        let movieService = MockMovieService()
        self.movieService = movieService
        self.viewModel = MovieDetailsViewModel(
            movieID: initialMovie?.id ?? 1,
            initialMovie: initialMovie,
            movieService: movieService
        )
    }

    func setDetails(_ details: MovieDetails, for id: Int) async {
        await movieService.setDetailsResponse(.success(details), for: id)
    }

    func setDetailsFailure(_ message: String, for id: Int) async {
        await movieService.setDetailsResponse(.failure(TestError(message)), for: id)
    }

    func loadDetails() async {
        await viewModel.loadDetails()
    }

    func requestedDetailIDs() async -> [Int] {
        await movieService.requestedDetailIDs()
    }
}

private actor LoadGate {
    private var continuation: CheckedContinuation<Void, Never>?

    func wait() async {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }

    func open() {
        continuation?.resume()
        continuation = nil
    }
}

private func makeMovie(id: Int, title: String) -> Movie {
    Movie(
        id: id,
        title: title,
        overview: "Overview for \(title)",
        posterPath: nil,
        backdropPath: nil,
        releaseDate: "2026-04-27",
        popularity: 8.0,
        voteAverage: 7.5,
        voteCount: 100
    )
}

private enum MockResponse: Sendable {
    case success(MoviePage)
    case failure(TestError)
    case gatedSuccess(MoviePage, LoadGate)
}

private struct TestError: LocalizedError, Sendable {
    let errorDescription: String?

    init(_ description: String) {
        errorDescription = description
    }
}

private func waitUntil(
    maxIterations: Int = 200,
    condition: @escaping @Sendable () async -> Bool
) async {
    for _ in 0..<maxIterations {
        if await condition() {
            return
        }

        await Task.yield()
    }

    Issue.record("Timed out waiting for async condition.")
}

private func makePage(page: Int, totalPages: Int, ids: [Int]) -> MoviePage {
    MoviePage(
        page: page,
        results: ids.map(makeMovie),
        totalPages: totalPages,
        totalResults: ids.count * totalPages
    )
}

private func makeMovie(id: Int) -> Movie {
    let releaseDay = id < 10 ? "0\(id)" : "\(id)"

    return Movie(
        id: id,
        title: "Movie \(id)",
        overview: "Overview \(id)",
        posterPath: nil,
        backdropPath: nil,
        releaseDate: "2026-04-\(releaseDay)",
        popularity: Double(id),
        voteAverage: 7.5,
        voteCount: 100 + id
    )
}

private func makeDetails(id: Int) -> MovieDetails {
    MovieDetails(
        id: id,
        title: "Movie \(id) Details",
        originalTitle: "Movie \(id) Details",
        overview: "Detailed overview \(id)",
        tagline: "The signal gets stronger.",
        posterPath: "/poster\(id).jpg",
        backdropPath: "/backdrop\(id).jpg",
        releaseDate: "2026-04-27",
        runtime: 126,
        status: "Released",
        homepage: nil,
        popularity: 11.4,
        voteAverage: 8.2,
        voteCount: 2048,
        genres: [
            MovieGenre(id: 28, name: "Action")
        ],
        credits: MovieCredits(
            cast: [
                MovieCastMember(id: 10, name: "Maya Chen", character: "Nova", profilePath: "/maya.jpg"),
                MovieCastMember(id: 11, name: "Jon Bell", character: "Rowe", profilePath: "/jon.jpg")
            ],
            crew: [
                MovieCrewMember(
                    id: 20,
                    name: "Rae Coleman",
                    job: "Director",
                    department: "Directing",
                    profilePath: nil
                )
            ]
        ),
        videos: MovieVideos(
            results: [
                MovieVideo(
                    id: "video-\(id)",
                    key: "abc123",
                    name: "Trailer",
                    site: "YouTube",
                    type: "Trailer",
                    official: true
                )
            ]
        )
    )
}
