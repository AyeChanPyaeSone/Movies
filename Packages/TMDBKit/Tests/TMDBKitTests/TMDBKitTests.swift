import Foundation
import Testing
@testable import TMDBKit

struct TMDBKitTests {

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
