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
            in: .popular,
            page: page,
            language: language,
            region: region
        )

        return moviePage.results
    }

    public func listMoviesPage(
        in category: MovieListCategory = .popular,
        page: Int = 1,
        language: String? = nil,
        region: String? = nil
    ) async throws -> MoviePage {
        let normalizedPage = max(1, page)
        let endpoint = TMDBEndpoint.movieList(
            category: category,
            page: normalizedPage,
            language: language ?? configuration.defaultLanguage,
            region: region ?? configuration.defaultRegion
        )

        TMDBLogger.network.debug("Starting \(category.logName) movies request for page \(normalizedPage).")

        do {
            let request = try makeRequest(for: endpoint)
            let (data, response) = try await session.data(for: request)
            let moviePage: MoviePage = try decodeResponse(data: data, response: response)

            TMDBLogger.network.info(
                "Received \(category.logName) movies page \(moviePage.page) containing \(moviePage.results.count) results."
            )

            return moviePage
        } catch {
            TMDBLogger.network.error(
                "\(category.logName.capitalized) movies request failed for page \(normalizedPage): \(String(describing: error))"
            )
            throw error
        }
    }

    public func listTopRatedMovies(
        page: Int = 1,
        language: String? = nil,
        region: String? = nil
    ) async throws -> [Movie] {
        try await listMovies(
            in: .topRated,
            page: page,
            language: language,
            region: region
        )
    }

    public func listTopRatedMoviesPage(
        page: Int = 1,
        language: String? = nil,
        region: String? = nil
    ) async throws -> MoviePage {
        try await listMoviesPage(
            in: .topRated,
            page: page,
            language: language,
            region: region
        )
    }

    public func listUpcomingMovies(
        page: Int = 1,
        language: String? = nil,
        region: String? = nil
    ) async throws -> [Movie] {
        try await listMovies(
            in: .upcoming,
            page: page,
            language: language,
            region: region
        )
    }

    public func listUpcomingMoviesPage(
        page: Int = 1,
        language: String? = nil,
        region: String? = nil
    ) async throws -> MoviePage {
        try await listMoviesPage(
            in: .upcoming,
            page: page,
            language: language,
            region: region
        )
    }

    public func listNowPlayingMovies(
        page: Int = 1,
        language: String? = nil,
        region: String? = nil
    ) async throws -> [Movie] {
        try await listMovies(
            in: .nowPlaying,
            page: page,
            language: language,
            region: region
        )
    }

    public func listNowPlayingMoviesPage(
        page: Int = 1,
        language: String? = nil,
        region: String? = nil
    ) async throws -> MoviePage {
        try await listMoviesPage(
            in: .nowPlaying,
            page: page,
            language: language,
            region: region
        )
    }

    public func listMovies(
        in category: MovieListCategory,
        page: Int = 1,
        language: String? = nil,
        region: String? = nil
    ) async throws -> [Movie] {
        let moviePage = try await listMoviesPage(
            in: category,
            page: page,
            language: language,
            region: region
        )

        return moviePage.results
    }

    public func movieDetails(
        id: Int,
        language: String? = nil,
        appendToResponse: [String] = ["credits", "videos"]
    ) async throws -> MovieDetails {
        let endpoint = TMDBEndpoint.movieDetails(
            id: id,
            language: language ?? configuration.defaultLanguage,
            appendToResponse: appendToResponse
        )

        TMDBLogger.network.debug("Starting movie details request for movie \(id).")

        do {
            let request = try makeRequest(for: endpoint)
            let (data, response) = try await session.data(for: request)
            let details: MovieDetails = try decodeResponse(data: data, response: response)

            TMDBLogger.network.info("Received movie details for movie \(details.id): \(details.title).")

            return details
        } catch {
            TMDBLogger.network.error(
                "Movie details request failed for movie \(id): \(String(describing: error))"
            )
            throw error
        }
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

    private func decodeResponse<Response: Decodable>(
        data: Data,
        response: URLResponse
    ) throws -> Response {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TMDBError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let message = String(data: data, encoding: .utf8)
            throw TMDBError.requestFailed(statusCode: httpResponse.statusCode, message: message)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(Response.self, from: data)
    }
}
