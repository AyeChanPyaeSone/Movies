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
}
