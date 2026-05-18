import Testing
import TMDBKit
@testable import Movies

struct MovieServiceTests {
    @Test("Movie service convenience methods request the matching TMDB category", arguments: [
        MovieServiceExpectation(method: .popular, page: 1, expectedCategory: .popular),
        MovieServiceExpectation(method: .topRated, page: 2, expectedCategory: .topRated),
        MovieServiceExpectation(method: .upcoming, page: 3, expectedCategory: .upcoming),
        MovieServiceExpectation(method: .nowPlaying, page: 4, expectedCategory: .nowPlaying),
    ])
    func convenienceMethodsUseExpectedCategories(_ expectation: MovieServiceExpectation) async throws {
        let service = RecordingMovieService()

        let moviePage = switch expectation.method {
        case .popular:
            try await service.fetchPopularMoviesPage(expectation.page)
        case .topRated:
            try await service.fetchTopRatedMoviesPage(expectation.page)
        case .upcoming:
            try await service.fetchUpcomingMoviesPage(expectation.page)
        case .nowPlaying:
            try await service.fetchNowPlayingMoviesPage(expectation.page)
        }

        let request = await service.singleRequest()

        #expect(request.category == expectation.expectedCategory)
        #expect(request.page == expectation.page)
        #expect(moviePage.page == expectation.page)
    }
}

struct MovieServiceExpectation: Sendable {
    let method: MovieServiceMethod
    let page: Int
    let expectedCategory: MovieListCategory
}

enum MovieServiceMethod: Sendable {
    case popular
    case topRated
    case upcoming
    case nowPlaying
}

private actor RecordingMovieService: MovieService {
    private var requests: [MovieServiceRequest] = []

    func fetchMoviesPage(in category: MovieListCategory, page: Int) async throws -> MoviePage {
        let request = MovieServiceRequest(category: category, page: page)
        requests.append(request)

        return MoviePage(
            page: page,
            results: [],
            totalPages: 1,
            totalResults: 0
        )
    }

    func fetchMovieDetails(id: Int) async throws -> MovieDetails {
        MovieDetails(
            id: id,
            title: "Movie \(id)",
            overview: "Overview \(id)",
            posterPath: nil,
            backdropPath: nil,
            releaseDate: nil,
            runtime: nil,
            popularity: 0,
            voteAverage: 0,
            voteCount: 0
        )
    }

    func singleRequest() -> MovieServiceRequest {
        requests[0]
    }
}

private struct MovieServiceRequest: Sendable {
    let category: MovieListCategory
    let page: Int
}
