import Foundation

enum TMDBEndpoint {
    case movieDetails(id: Int, language: String, appendToResponse: [String])
    case movieList(category: MovieListCategory, page: Int, language: String, region: String?)

    var path: String {
        switch self {
        case .movieDetails(let id, _, _):
            return "/movie/\(id)"
        case .movieList(let category, _, _, _):
            return "/movie/\(category.pathComponent)"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .movieList(_, let page, let language, let region):
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
