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
    private var detailIDs: [Int] = []
    private var detailResponses: [Int: Result<MovieDetails, TestError>] = [:]
    private var responses: [MovieServiceRequest: MockResponse] = [:]

    func setResponse(_ response: MockResponse, for category: MovieListCategory, page: Int) {
        responses[MovieServiceRequest(category: category, page: page)] = response
    }

    func requests() -> [MovieServiceRequest] {
        capturedRequests
    }

    func setDetailsResponse(_ response: Result<MovieDetails, TestError>, for id: Int) {
        detailResponses[id] = response
    }

    func requestedDetailIDs() -> [Int] {
        detailIDs
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

private enum MockResponse: Sendable {
    case success(MoviePage)
    case failure(TestError)
}

private struct MovieServiceRequest: Hashable, Sendable {
    let category: MovieListCategory
    let page: Int
}

private struct TestError: LocalizedError, Sendable {
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

private func makeMovie(id: Int) -> Movie {
    makeMovie(id: id, title: "Movie \(id)")
}
