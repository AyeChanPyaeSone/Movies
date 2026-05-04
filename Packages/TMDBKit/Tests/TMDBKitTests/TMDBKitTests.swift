import Foundation
import Testing
@testable import TMDBKit

@Suite(.serialized)
struct TMDBKitTests {

    @Test
    func placeholderAuthorizationFailsEarly() {
        let client = TMDBClient(
            configuration: TMDBConfiguration(
                authorization: .placeholder
            )
        )

        #expect(throws: TMDBError.missingAuthorization) {
            try client.makeRequest(
                for: .movieList(category: .popular, page: 1, language: "en-US", region: nil)
            )
        }
    }

    @Test("Movie list request targets the expected endpoint", arguments: [
        MovieEndpointExpectation(
            category: .topRated,
            page: 3,
            language: "fr-FR",
            region: "FR",
            expectedPath: "/3/movie/top_rated"
        ),
        MovieEndpointExpectation(
            category: .upcoming,
            page: 2,
            language: "en-US",
            region: nil,
            expectedPath: "/3/movie/upcoming"
        ),
        MovieEndpointExpectation(
            category: .nowPlaying,
            page: 4,
            language: "es-ES",
            region: "ES",
            expectedPath: "/3/movie/now_playing"
        ),
    ])
    func movieListRequestTargetsExpectedEndpoint(_ expectation: MovieEndpointExpectation) throws {
        let client = TMDBClient(
            configuration: TMDBConfiguration(
                authorization: .bearerToken("token")
            )
        )

        let request = try client.makeRequest(
            for: .movieList(
                category: expectation.category,
                page: expectation.page,
                language: expectation.language,
                region: expectation.region
            )
        )

        let requestURL = try #require(request.url)
        let components = try #require(URLComponents(url: requestURL, resolvingAgainstBaseURL: false))

        #expect(request.httpMethod == "GET")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer token")
        #expect(components.path == expectation.expectedPath)
        #expect(components.queryItems?.first(where: { $0.name == "language" })?.value == expectation.language)
        #expect(components.queryItems?.first(where: { $0.name == "page" })?.value == String(expectation.page))
        #expect(components.queryItems?.first(where: { $0.name == "region" })?.value == expectation.region)
    }

    @Test
    func movieDetailsRequestUsesAppendToResponse() throws {
        let client = TMDBClient(
            configuration: TMDBConfiguration(
                authorization: .apiKey("test-key")
            )
        )

        let request = try client.makeRequest(
            for: .movieDetails(
                id: 550,
                language: "en-US",
                appendToResponse: ["credits", "videos"]
            )
        )

        let url = try #require(request.url)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let queryItems = components.queryItems ?? []

        #expect(components.path == "/3/movie/550")
        #expect(queryItems.contains(URLQueryItem(name: "language", value: "en-US")))
        #expect(queryItems.contains(URLQueryItem(name: "append_to_response", value: "credits,videos")))
        #expect(queryItems.contains(URLQueryItem(name: "api_key", value: "test-key")))
    }

    @Test("Upcoming and now playing pages decode release windows", arguments: [
        MovieListCategory.upcoming,
        .nowPlaying,
    ])
    func moviePagesDecodeReleaseWindows(_ category: MovieListCategory) async throws {
        let session = makeSession(
            responseData: """
            {
              "dates": {
                "maximum": "2026-05-31",
                "minimum": "2026-05-01"
              },
              "page": 1,
              "results": [
                {
                  "id": 101,
                  "title": "Future Echo",
                  "overview": "A test movie",
                  "poster_path": "/poster.jpg",
                  "backdrop_path": "/backdrop.jpg",
                  "release_date": "2026-05-14",
                  "popularity": 42.0,
                  "vote_average": 8.4,
                  "vote_count": 1200
                }
              ],
              "total_pages": 8,
              "total_results": 160
            }
            """
        )

        let client = TMDBClient(
            configuration: TMDBConfiguration(
                authorization: .bearerToken("token"),
                defaultLanguage: "en-US",
                defaultRegion: "US"
            ),
            session: session
        )

        let moviePage = try await client.listMoviesPage(in: category, page: 0)
        let request = try #require(MockURLProtocol.recordedRequest)
        let requestURL = try #require(request.url)
        let components = try #require(URLComponents(url: requestURL, resolvingAgainstBaseURL: false))

        #expect(moviePage.dates == MovieReleaseWindow(maximum: "2026-05-31", minimum: "2026-05-01"))
        #expect(moviePage.results.map(\.id) == [101])
        #expect(components.path == "/3/movie/\(category.pathComponent)")
        #expect(components.queryItems?.first(where: { $0.name == "page" })?.value == "1")
        #expect(components.queryItems?.first(where: { $0.name == "region" })?.value == "US")
    }

    @Test
    func topRatedMovieConvenienceReturnsResults() async throws {
        let session = makeSession(
            responseData: """
            {
              "page": 1,
              "results": [
                {
                  "id": 7,
                  "title": "All-Time Favorite",
                  "overview": "A test movie",
                  "poster_path": null,
                  "backdrop_path": null,
                  "release_date": "2025-12-24",
                  "popularity": 90.0,
                  "vote_average": 9.8,
                  "vote_count": 4000
                }
              ],
              "total_pages": 1,
              "total_results": 1
            }
            """
        )

        let client = TMDBClient(
            configuration: TMDBConfiguration(
                authorization: .bearerToken("token")
            ),
            session: session
        )

        let movies = try await client.listTopRatedMovies()

        #expect(movies == [
            Movie(
                id: 7,
                title: "All-Time Favorite",
                overview: "A test movie",
                posterPath: nil,
                backdropPath: nil,
                releaseDate: "2025-12-24",
                popularity: 90.0,
                voteAverage: 9.8,
                voteCount: 4000
            )
        ])
    }

    @Test
    func movieDetailsDecodesAppendedCreditsAndVideos() throws {
        let json = """
        {
          "id": 550,
          "title": "Fight Club",
          "original_title": "Fight Club",
          "overview": "A ticking-time-bomb insomniac meets a soap salesman.",
          "tagline": "Mischief. Mayhem. Soap.",
          "poster_path": "/poster.jpg",
          "backdrop_path": "/backdrop.jpg",
          "release_date": "1999-10-15",
          "runtime": 139,
          "status": "Released",
          "homepage": "https://example.com",
          "popularity": 55.2,
          "vote_average": 8.4,
          "vote_count": 29000,
          "genres": [
            { "id": 18, "name": "Drama" }
          ],
          "credits": {
            "cast": [
              {
                "id": 819,
                "name": "Edward Norton",
                "character": "Narrator",
                "profile_path": "/profile.jpg",
                "order": 0
              }
            ],
            "crew": [
              {
                "id": 7467,
                "name": "David Fincher",
                "job": "Director",
                "department": "Directing",
                "profile_path": "/director.jpg"
              }
            ]
          },
          "videos": {
            "results": [
              {
                "id": "video-1",
                "key": "abc123",
                "name": "Official Trailer",
                "site": "YouTube",
                "type": "Trailer",
                "official": true,
                "published_at": "1999-09-01T00:00:00.000Z",
                "size": 1080
              }
            ]
          }
        }
        """

        let data = try #require(json.data(using: .utf8))
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let details = try decoder.decode(MovieDetails.self, from: data)

        #expect(details.id == 550)
        #expect(details.runtime == 139)
        #expect(details.genres == [MovieGenre(id: 18, name: "Drama")])
        #expect(details.credits?.cast.first?.name == "Edward Norton")
        #expect(details.credits?.crew.first?.job == "Director")
        #expect(details.videos?.results.first?.key == "abc123")
    }
}

struct MovieEndpointExpectation: Sendable {
    let category: MovieListCategory
    let page: Int
    let language: String
    let region: String?
    let expectedPath: String
}

private func makeSession(
    responseData: String,
    statusCode: Int = 200
) -> URLSession {
    MockURLProtocol.recordedRequest = nil
    MockURLProtocol.requestHandler = { request in
        MockURLProtocol.recordedRequest = request

        let response = HTTPURLResponse(
            url: try #require(request.url),
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!

        return (response, Data(responseData.utf8))
    }

    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: configuration)
}

private final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var recordedRequest: URLRequest?
    nonisolated(unsafe) static var requestHandler: (@Sendable (URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            Issue.record("Missing URLProtocol request handler.")
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
