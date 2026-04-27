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
                if viewModel.isLoading && viewModel.movies.isEmpty {
                    ProgressView("Loading Movies")
                } else if viewModel.movies.isEmpty {
                    ContentUnavailableView {
                        Label("No Movies Loaded", systemImage: "film.stack")
                    } description: {
                        Text("Set `TMDB_BEARER_TOKEN` or `TMDBBearerToken`, then tap Load Movies.")
                    } actions: {
                        Button("Load Movies", action: refreshMovies)
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(viewModel.movies) { movie in
                            MovieRowView(movie: movie)
                                .task(id: movie.id) {
                                    await viewModel.loadNextPageIfNeeded(currentMovie: movie)
                                }
                        }

                        if viewModel.isLoadingMore {
                            HStack {
                                Spacer()
                                ProgressView("Loading more movies")
                                Spacer()
                            }
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .task {
                guard viewModel.movies.isEmpty else {
                    return
                }

                await viewModel.loadMovies()
            }
            .navigationTitle("Popular Movies")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(viewModel.isLoading ? "Loading..." : toolbarButtonTitle, action: refreshMovies)
                        .disabled(viewModel.isLoading && viewModel.movies.isEmpty)
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

    private var toolbarButtonTitle: String {
        viewModel.movies.isEmpty ? "Load Movies" : "Refresh"
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

    private func refreshMovies() {
        Task {
            await viewModel.loadMovies(reset: true)
        }
    }
}

#Preview {
    MoviesListView(
        movieService: PreviewMovieService(
            moviePage: MoviePage(
                page: 1,
                results: [
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
                ],
                totalPages: 1,
                totalResults: 1
            )
        )
    )
}

private struct PreviewMovieService: MovieService {
    let moviePage: MoviePage

    func fetchPopularMoviesPage(_ page: Int) async throws -> MoviePage {
        moviePage
    }
}
