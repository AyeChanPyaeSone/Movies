import SwiftUI
import TMDBKit

struct MoviesListView: View {
    @State private var viewModel: MoviesListViewModel
    @State private var selectedTab: MoviesListTab = .home
    @State private var isShowingError = false
    @State private var navigationPath: [MoviesListRoute] = []

    init(movieService: any MovieService) {
        _viewModel = State(initialValue: MoviesListViewModel(movieService: movieService))
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack(path: $navigationPath) {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 7 / 255, green: 11 / 255, blue: 34 / 255),
                        Color(red: 9 / 255, green: 18 / 255, blue: 55 / 255),
                        Color(red: 17 / 255, green: 26 / 255, blue: 74 / 255)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                Group {
                    if viewModel.isLoading && viewModel.movies.isEmpty {
                        ProgressView("Loading Movies")
                            .tint(.white)
                            .foregroundStyle(.white)
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
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 20) {
                                MoviesSearchFieldView(searchText: $viewModel.searchText)

                                if let featuredMovie = viewModel.featuredMovie {
                                    MoviesHeroCardView(
                                        movie: featuredMovie,
                                        playAction: refreshMovies,
                                        detailsAction: {
                                            navigationPath.append(.movieDetails(featuredMovie.id))
                                        }
                                    )
                                }

                                if viewModel.visibleSections.isEmpty {
                                    ContentUnavailableView.search(text: viewModel.searchText)
                                        .foregroundStyle(.white)
                                } else {
                                    ForEach(viewModel.visibleSections) { section in
                                        MovieRowView(
                                            section: section,
                                            categoryAction: showCategory,
                                            loadMoreAction: { section, movie in
                                                await viewModel.loadNextPageIfNeeded(
                                                    in: section,
                                                    currentMovie: movie,
                                                    source: .homeShelf
                                                )
                                            }
                                        )
                                    }
                                }

                                if viewModel.isLoadingMore {
                                    HStack {
                                        Spacer()
                                        ProgressView("Loading more movies")
                                            .tint(.white)
                                            .foregroundStyle(.white.opacity(0.8))
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 12)
                            .padding(.bottom, 24)
                        }
                        .contentMargins(.horizontal, 16, for: .scrollContent)
                        .scrollIndicators(.hidden)
                    }
                }
            }
            .task {
                await loadInitialMoviesIfNeeded()
            }
            .onChange(of: viewModel.errorMessage) { _, newValue in
                isShowingError = newValue != nil
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: MoviesListRoute.self) { route in
                switch route {
                case .movieDetails(let movieID):
                    MovieDetailsView(
                        movieID: movieID,
                        initialMovie: viewModel.movies.first { $0.id == movieID },
                        movieService: viewModel.movieService
                    )
                case .category(let category):
                    MoviesCategoryView(
                        category: category,
                        viewModel: viewModel
                    )
                }
            }
            .safeAreaInset(edge: .bottom) {
                MoviesListTabBarView(selection: $selectedTab)
            }
            .alert(
                "Unable to Load Movies",
                isPresented: $isShowingError,
                actions: {
                    Button("OK", role: .cancel, action: dismissError)
                },
                message: {
                    Text(viewModel.errorMessage ?? "")
                }
            )
        }
    }

    private func loadInitialMoviesIfNeeded() async {
        guard viewModel.movies.isEmpty else {
            return
        }

        await viewModel.loadMovies()
    }

    private func refreshMovies() {
        Task {
            await viewModel.loadMovies(reset: true)
        }
    }

    private func showCategory(_ category: MovieListCategory) {
        PerformanceTracker.record(
            .moviesList(.openCategory),
            tags: ["category": category.metricName]
        )
        navigationPath.append(.category(category))
    }

    private func dismissError() {
        viewModel.dismissError()
    }
}

#Preview {
    MoviesListView(movieService: MoviesListPreviewMovieService())
}
