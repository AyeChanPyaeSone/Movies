import Foundation
import TMDBKit

extension MovieDetails {
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

    var runtimeText: String? {
        guard let runtime else {
            return nil
        }

        let hours = runtime / 60
        let minutes = runtime % 60

        if hours == 0 {
            return "\(minutes)m"
        }

        return "\(hours)h \(minutes)m"
    }

    var preferredTrailer: MovieVideo? {
        videos?.results.first {
            $0.site == "YouTube" && $0.type == "Trailer" && ($0.official ?? false)
        } ?? videos?.results.first {
            $0.site == "YouTube" && $0.type == "Trailer"
        } ?? videos?.results.first {
            $0.site == "YouTube"
        }
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

extension MovieCastMember {
    var profileURL: URL? {
        guard let profilePath else {
            return nil
        }

        guard let baseURL = URL(string: "https://image.tmdb.org/t/p") else {
            return nil
        }

        let cleanedPath = profilePath.hasPrefix("/") ? String(profilePath.dropFirst()) : profilePath
        return baseURL
            .appending(path: "w185")
            .appending(path: cleanedPath)
    }
}

extension MovieVideo {
    var youtubeURL: URL? {
        guard site == "YouTube" else {
            return nil
        }

        return URL(string: "https://www.youtube.com/watch?v=\(key)")
    }
}
