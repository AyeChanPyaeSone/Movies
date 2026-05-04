import Foundation

enum TMDBEndpoint {
    case popularMovies(page: Int, language: String, region: String?)
    case movieDetails(id: Int, language: String, appendToResponse: [String])

    var path: String {
        switch self {
        case .popularMovies:
            return "/movie/popular"
        case .movieDetails(let id, _, _):
            return "/movie/\(id)"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .popularMovies(let page, let language, let region):
            var items = [
                URLQueryItem(name: "language", value: language),
                URLQueryItem(name: "page", value: String(page)),
            ]

            if let region, !region.isEmpty {
                items.append(URLQueryItem(name: "region", value: region))
            }

            return items
        case .movieDetails(_, let language, let appendToResponse):
            var items = [
                URLQueryItem(name: "language", value: language),
            ]

            if !appendToResponse.isEmpty {
                items.append(
                    URLQueryItem(
                        name: "append_to_response",
                        value: appendToResponse.joined(separator: ",")
                    )
                )
            }

            return items
        }
    }
}
