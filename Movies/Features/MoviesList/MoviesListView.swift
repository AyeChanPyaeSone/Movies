import SwiftUI
import TMDBKit

struct MoviesListView: View {
    @State private var viewModel: MoviesListViewModel

    init(movieService: any MovieService) {
        _viewModel = State(initialValue: MoviesListViewModel(movieService: movieService))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.movies.isEmpty {
                    ContentUnavailableView {
                        Label("No Movies Loaded", systemImage: "film.stack")
                    } description: {
                        Text("Add your TMDB credential in AppContainer, then tap Load Movies.")
                    } actions: {
                        Button("Load Movies", action: loadMovies)
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    List(viewModel.movies) { movie in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(movie.title)
                                .font(.headline)

                            if let releaseDate = movie.releaseDate, !releaseDate.isEmpty {
                                Text(releaseDate)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Text(movie.overview)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .lineLimit(3)
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Popular Movies")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(viewModel.isLoading ? "Loading..." : "Load Movies", action: loadMovies)
                        .disabled(viewModel.isLoading)
                }
            }
            .alert(
                "Unable to Load Movies",
                isPresented: errorAlertIsPresented,
                actions: {
                    Button("OK", role: .cancel) {}
                },
                message: {
                    Text(viewModel.errorMessage ?? "")
                }
            )
        }
    }

    private var errorAlertIsPresented: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.dismissError()
                }
            }
        )
    }

    private func loadMovies() {
        Task {
            await viewModel.loadMovies()
        }
    }
}

#Preview {
    MoviesListView(
        movieService: PreviewMovieService(
            movies: [
                Movie(
                    id: 1,
                    title: "The Codex Cut",
                    overview: "A refactored movie app finally gets the architecture it deserved.",
                    posterPath: nil,
                    backdropPath: nil,
                    releaseDate: "2026-04-27",
                    popularity: 9.4,
                    voteAverage: 8.7,
                    voteCount: 1280
                )
            ]
        )
    )
}

private struct PreviewMovieService: MovieService {
    let movies: [Movie]

    func listMovies() async throws -> [Movie] {
        movies
    }
}
