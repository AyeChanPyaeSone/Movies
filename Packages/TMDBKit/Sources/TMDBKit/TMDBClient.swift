import Foundation

public struct TMDBClient: Sendable {
    public let configuration: TMDBConfiguration
    private let session: URLSession

    public init(configuration: TMDBConfiguration, session: URLSession = .shared) {
        self.configuration = configuration
        self.session = session
    }

    public func listMovies(
        page: Int = 1,
        language: String? = nil,
        region: String? = nil
    ) async throws -> [Movie] {
        let moviePage = try await listMoviesPage(
            page: page,
            language: language,
            region: region
        )

        return moviePage.results
    }

    public func listMoviesPage(
        page: Int = 1,
        language: String? = nil,
        region: String? = nil
    ) async throws -> MoviePage {
        let endpoint = TMDBEndpoint.popularMovies(
            page: max(1, page),
            language: language ?? configuration.defaultLanguage,
            region: region ?? configuration.defaultRegion
        )

        let request = try makeRequest(for: endpoint)
        let (data, response) = try await session.data(for: request)
        return try decodeResponse(data: data, response: response)
    }

    func makeRequest(for endpoint: TMDBEndpoint) throws -> URLRequest {
        let normalizedPath = endpoint.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let endpointURL = configuration.baseURL.appendingPathComponent(normalizedPath)

        guard var components = URLComponents(url: endpointURL, resolvingAgainstBaseURL: false) else {
            throw TMDBError.invalidRequest
        }

        components.queryItems = endpoint.queryItems

        var headers = [
            "Accept": "application/json",
        ]
        try configuration.authorization.apply(to: &components, headers: &headers)

        guard let url = components.url else {
            throw TMDBError.invalidRequest
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }

    private func decodeResponse(data: Data, response: URLResponse) throws -> MoviePage {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TMDBError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let message = String(data: data, encoding: .utf8)
            throw TMDBError.requestFailed(statusCode: httpResponse.statusCode, message: message)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(MoviePage.self, from: data)
    }
}
