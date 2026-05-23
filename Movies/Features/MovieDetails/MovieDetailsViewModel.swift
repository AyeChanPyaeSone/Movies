import Foundation
import LoggingKit
import Observation
import OSLog
import TMDBKit

@MainActor
@Observable
final class MovieDetailsViewModel {
    private(set) var details: MovieDetails?
    private(set) var errorMessage: String?
    private(set) var isLoading = false

    let movieID: Int
    let initialMovie: Movie?

    @ObservationIgnored
    private let movieService: any MovieService
    @ObservationIgnored
    private let signposter: OSSignposter

    init(
        movieID: Int,
        initialMovie: Movie?,
        movieService: any MovieService,
        signposter: OSSignposter? = nil
    ) {
        self.movieID = movieID
        self.initialMovie = initialMovie
        self.movieService = movieService
        self.signposter = signposter ?? MoviesLogger.movieDetailsSignposter
    }

    var title: String {
        details?.title ?? initialMovie?.title ?? "Movie Details"
    }

    var overview: String {
        details?.overview ?? initialMovie?.overview ?? ""
    }

    var releaseYear: String? {
        details?.releaseYear ?? initialMovie?.releaseYear
    }

    var rating: Double {
        details?.voteAverage ?? initialMovie?.voteAverage ?? 0
    }

    var voteCount: Int {
        details?.voteCount ?? initialMovie?.voteCount ?? 0
    }

    var posterURL: URL? {
        details?.posterURL ?? initialMovie?.posterURL
    }

    var backdropURL: URL? {
        details?.backdropURL ?? initialMovie?.backdropURL
    }

    var trailerURL: URL? {
        details?.preferredTrailer?.youtubeURL
    }

    var cast: [MovieCastMember] {
        Array((details?.credits?.cast ?? []).prefix(12))
    }

    var directors: [MovieCrewMember] {
        (details?.credits?.crew ?? []).filter { $0.job == "Director" }
    }

    func loadDetailsIfNeeded() async {
        guard details == nil else {
            return
        }

        await loadDetails()
    }

    func loadDetails() async {
        guard !isLoading else {
            MoviesLogger.movieDetails.debug(
                "Skipped movie details load because another request is already in flight."
            )
            return
        }

        let intervalState = signposter.beginInterval(
            "Load Movie Details",
            id: signposter.makeSignpostID(),
            "movie \(self.movieID)"
        )

        isLoading = true
        errorMessage = nil
        defer {
            signposter.endInterval("Load Movie Details", intervalState)
            isLoading = false
        }

        do {
            MoviesLogger.movieDetails.info("Starting movie details load for movie \(movieID).")
            details = try await PerformanceTracker.track(
                .movieDetails(.loadDetails)
            ) {
                try await movieService.fetchMovieDetails(id: movieID)
            }
            MoviesLogger.movieDetails.info("Loaded movie details for movie \(movieID).")
        } catch {
            MoviesLogger.movieDetails.error(
                "Movie details load failed for movie \(movieID): \(String(describing: error))"
            )
            ErrorReporter.capture(
                error,
                context: .movieDetails
            )
            showError(error)
        }
    }

    func dismissError() {
        errorMessage = nil
    }
}

private extension MovieDetailsViewModel {
    func showError(_ error: Error) {
        if let localizedError = error as? LocalizedError,
           let description = localizedError.errorDescription {
            errorMessage = description
        } else {
            errorMessage = error.localizedDescription
        }
    }
}
