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

    func setResponse(_ response: MockResponse, for page: Int) {
        responses[page] = response
    }

    func requestedPages() -> [Int] {
        pages
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

private enum MockResponse: Sendable {
    case success(MoviePage)
    case failure(TestError)
    case gatedSuccess(MoviePage, LoadGate)
}

private struct TestError: LocalizedError {
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
