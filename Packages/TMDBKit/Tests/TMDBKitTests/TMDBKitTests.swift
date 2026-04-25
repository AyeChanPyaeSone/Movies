import Foundation
import Testing
@testable import TMDBKit

struct TMDBKitTests {

    @Test
    func listMoviesUsesPopularMoviesEndpoint() throws {
        let client = TMDBClient(
            configuration: TMDBConfiguration(
                authorization: .apiKey("demo-key"),
                defaultLanguage: "en-US",
                defaultRegion: "US"
            )
        )

        let request = try client.makeRequest(for: .popularMovies(page: 2, language: "en-US", region: "US"))

        #expect(request.url?.absoluteString == "https://api.themoviedb.org/3/movie/popular?language=en-US&page=2&region=US&api_key=demo-key")
        #expect(request.httpMethod == "GET")
    }

    @Test
    func placeholderAuthorizationFailsEarly() {
        let client = TMDBClient(
            configuration: TMDBConfiguration(
                authorization: .placeholder
            )
        )

        #expect(throws: TMDBError.missingAuthorization) {
            try client.makeRequest(for: .popularMovies(page: 1, language: "en-US", region: nil))
        }
    }
}
