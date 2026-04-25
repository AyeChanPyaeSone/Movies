import Foundation
import Observation
import TMDBKit

@MainActor
@Observable
final class MoviesViewModel {
    private(set) var movies: [Movie] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    func loadMovies() async {
        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            movies = try await AppDependencies.movieClient.listMovies()
        } catch {
            if let localizedError = error as? LocalizedError,
               let description = localizedError.errorDescription {
                errorMessage = description
            } else {
                errorMessage = error.localizedDescription
            }

            movies = []
        }

        isLoading = false
    }

    func dismissError() {
        errorMessage = nil
    }
}
