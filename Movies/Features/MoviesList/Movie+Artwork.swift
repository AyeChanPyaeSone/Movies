import Foundation
import TMDBKit

extension Movie {
    var posterURL: URL? {
        makeArtworkURL(width: "w342", path: posterPath)
    }

    var backdropURL: URL? {
        makeArtworkURL(width: "w780", path: backdropPath)
    }

    var releaseYear: String? {
        guard let releaseDate, let year = releaseDate.split(separator: "-").first else {
            return nil
        }

        return String(year)
    }

    private func makeArtworkURL(width: String, path: String?) -> URL? {
        guard let path else {
            return nil
        }

        guard let baseURL = URL(string: "https://image.tmdb.org/t/p") else {
            return nil
        }

        let cleanedPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        return baseURL
            .appending(path: width)
            .appending(path: cleanedPath)
    }
}
