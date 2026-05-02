import Foundation

enum TMDBEndpoint {
    case movieList(category: MovieListCategory, page: Int, language: String, region: String?)

    var path: String {
        switch self {
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
        }
    }
}
