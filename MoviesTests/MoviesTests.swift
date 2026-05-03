import Foundation
import Testing
import TMDBKit
@testable import Movies

struct MoviesTests {
    @MainActor
    @Test("Initial home load builds real TMDB shelves")
    func initialLoadBuildsShelves() async {
        let harness = MoviesListHarness()

        await harness.setPage(makePage(page: 1, totalPages: 2, ids: [101, 102]), for: .topRated, page: 1)
        await harness.setPage(makePage(page: 1, totalPages: 1, ids: [201, 202]), for: .upcoming, page: 1)
        await harness.setPage(makePage(page: 1, totalPages: 2, ids: [301, 302, 303]), for: .nowPlaying, page: 1)

        await harness.loadFirstPage()

        #expect(harness.viewModel.featuredMovie?.id == 301)
        #expect(harness.viewModel.visibleSections.map(\.title) == ["Top Rated", "Upcoming", "Now Playing"])
        #expect(harness.viewModel.visibleSections.first(where: { $0.category == .topRated })?.movies.map(\.id) == [101, 102])
        #expect(harness.viewModel.visibleSections.first(where: { $0.category == .upcoming })?.movies.map(\.id) == [201, 202])
        #expect(harness.viewModel.visibleSections.first(where: { $0.category == .nowPlaying })?.movies.map(\.id) == [302, 303])
        #expect(harness.viewModel.errorMessage == nil)
        #expect(await harness.requestedRequests() == [
            MovieServiceRequest(category: .topRated, page: 1),
            MovieServiceRequest(category: .upcoming, page: 1),
            MovieServiceRequest(category: .nowPlaying, page: 1),
        ])
    }

    @MainActor
    @Test("Search filters across all real shelves and switches to results mode")
    func searchFiltersAcrossShelves() async {
        let harness = MoviesListHarness()

        await harness.setPage(
            MoviePage(
                page: 1,
                results: [
                    makeMovie(id: 1, title: "Stellar Odyssey"),
                    makeMovie(id: 2, title: "Paper Kingdom"),
                ],
                totalPages: 1,
                totalResults: 2
            ),
            for: .topRated,
            page: 1
        )
        await harness.setPage(
            MoviePage(
                page: 1,
                results: [
                    makeMovie(id: 3, title: "Comedy Night"),
                    makeMovie(id: 4, title: "Stellar Harbor"),
                ],
                totalPages: 1,
                totalResults: 2
            ),
            for: .upcoming,
            page: 1
        )
        await harness.setPage(
            MoviePage(
                page: 1,
                results: [
                    makeMovie(id: 5, title: "Galactic Run"),
                ],
                totalPages: 1,
                totalResults: 1
            ),
            for: .nowPlaying,
            page: 1
        )

        await harness.loadFirstPage()
        harness.viewModel.searchText = "stellar"

        #expect(harness.viewModel.featuredMovie == nil)
        #expect(harness.viewModel.visibleSections == [
            MoviesListSection(
                title: "Results",
                movies: [
                    makeMovie(id: 1, title: "Stellar Odyssey"),
                    makeMovie(id: 4, title: "Stellar Harbor"),
                ],
                category: nil
            )
        ])
    }

    @MainActor
    @Test("Loading the last movie of a shelf appends only that shelf's next page")
    func reachingShelfEndAppendsMatchingCategory() async throws {
        let harness = MoviesListHarness()

        await harness.setPage(makePage(page: 1, totalPages: 2, ids: [101, 102]), for: .topRated, page: 1)
        await harness.setPage(makePage(page: 1, totalPages: 1, ids: [201]), for: .upcoming, page: 1)
        await harness.setPage(makePage(page: 1, totalPages: 1, ids: [301, 302]), for: .nowPlaying, page: 1)
        await harness.setPage(makePage(page: 2, totalPages: 2, ids: [103]), for: .topRated, page: 2)

        await harness.loadFirstPage()
        try await harness.loadNextPage(in: .topRated)

        let topRatedMovies = try #require(
            harness.viewModel.visibleSections.first(where: { $0.category == .topRated })?.movies
        )

        #expect(topRatedMovies.map(\.id) == [101, 102, 103])
        #expect(await harness.requestedRequests() == [
            MovieServiceRequest(category: .topRated, page: 1),
            MovieServiceRequest(category: .upcoming, page: 1),
            MovieServiceRequest(category: .nowPlaying, page: 1),
            MovieServiceRequest(category: .topRated, page: 2),
        ])
    }

    @MainActor
    @Test("Pagination stops when a shelf reaches its final page")
    func noAppendOccursOnFinalShelfPage() async throws {
        let harness = MoviesListHarness()

        await harness.setPage(makePage(page: 1, totalPages: 1, ids: [101]), for: .topRated, page: 1)
        await harness.setPage(makePage(page: 1, totalPages: 1, ids: [201]), for: .upcoming, page: 1)
        await harness.setPage(makePage(page: 1, totalPages: 1, ids: [301, 302]), for: .nowPlaying, page: 1)

        await harness.loadFirstPage()
        try await harness.loadNextPage(in: .topRated)

        #expect(await harness.requestedRequests() == [
            MovieServiceRequest(category: .topRated, page: 1),
            MovieServiceRequest(category: .upcoming, page: 1),
            MovieServiceRequest(category: .nowPlaying, page: 1),
        ])
    }

    @MainActor
    @Test("Refresh failures keep the current shelves visible")
    func refreshFailureKeepsExistingShelves() async {
        let harness = MoviesListHarness()

        await harness.setPage(makePage(page: 1, totalPages: 1, ids: [101]), for: .topRated, page: 1)
        await harness.setPage(makePage(page: 1, totalPages: 1, ids: [201]), for: .upcoming, page: 1)
        await harness.setPage(makePage(page: 1, totalPages: 1, ids: [301, 302]), for: .nowPlaying, page: 1)

        await harness.loadFirstPage()
        await harness.setFailure("Upcoming failed", for: .upcoming, page: 1)
        await harness.refresh()

        #expect(harness.viewModel.visibleSections.map(\.title) == ["Top Rated", "Upcoming", "Now Playing"])
        #expect(harness.viewModel.errorMessage == "Upcoming failed")
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

    func setPage(_ moviePage: MoviePage, for category: MovieListCategory, page: Int) async {
        await movieService.setResponse(.success(moviePage), for: category, page: page)
    }

    func setFailure(_ message: String, for category: MovieListCategory, page: Int) async {
        await movieService.setResponse(.failure(TestError(message)), for: category, page: page)
    }

    func loadFirstPage() async {
        await viewModel.loadMovies()
    }

    func refresh() async {
        await viewModel.loadMovies(reset: true)
    }

    func loadNextPage(in category: MovieListCategory) async throws {
        let section = try #require(
            viewModel.visibleSections.first(where: { $0.category == category })
        )
        let lastMovie = try #require(section.movies.last)
        await viewModel.loadNextPageIfNeeded(in: section, currentMovie: lastMovie)
    }

    func requestedRequests() async -> [MovieServiceRequest] {
        await movieService.requests()
    }
}

private actor MockMovieService: MovieService {
    private var capturedRequests: [MovieServiceRequest] = []
    private var responses: [MovieServiceRequest: MockResponse] = [:]

    func setResponse(_ response: MockResponse, for category: MovieListCategory, page: Int) {
        responses[MovieServiceRequest(category: category, page: page)] = response
    }

    func requests() -> [MovieServiceRequest] {
        capturedRequests
    }

    func fetchMoviesPage(in category: MovieListCategory, page: Int) async throws -> MoviePage {
        let request = MovieServiceRequest(category: category, page: page)
        capturedRequests.append(request)

        guard let response = responses[request] else {
            throw TestError("Unexpected request: \(category) page \(page)")
        }

        switch response {
        case .success(let moviePage):
            return moviePage
        case .failure(let error):
            throw error
        }
    }
}

private enum MockResponse: Sendable {
    case success(MoviePage)
    case failure(TestError)
}

private struct MovieServiceRequest: Hashable, Sendable {
    let category: MovieListCategory
    let page: Int
}

private struct TestError: LocalizedError {
    let errorDescription: String?

    init(_ description: String) {
        errorDescription = description
    }
}

private func makePage(page: Int, totalPages: Int, ids: [Int]) -> MoviePage {
    MoviePage(
        page: page,
        results: ids.map(makeMovie),
        totalPages: totalPages,
        totalResults: ids.count * totalPages
    )
}

private func makeMovie(id: Int, title: String) -> Movie {
    Movie(
        id: id,
        title: title,
        overview: "Overview for \(title)",
        posterPath: nil,
        backdropPath: nil,
        releaseDate: "2026-04-27",
        popularity: Double(id),
        voteAverage: 7.5,
        voteCount: 100 + id
    )
}

private func makeMovie(id: Int) -> Movie {
    makeMovie(id: id, title: "Movie \(id)")
}
