import Foundation

enum TMDBEndpoint {
    case popularMovies(page: Int, language: String, region: String?)

    var path: String {
        switch self {
        case .popularMovies:
            return "/movie/popular"
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
        }
    }
}
