import SwiftUI
import TMDBKit

struct MoviesCategoryView: View {
    let category: MovieListCategory
    let viewModel: MoviesListViewModel

    private let columns = [
        GridItem(.adaptive(minimum: 112), spacing: 16, alignment: .top)
    ]

    var body: some View {
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

            if let section = viewModel.categorySection(for: category) {
                ScrollView {
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 18) {
                        ForEach(section.movies) { movie in
                            NavigationLink(value: MoviesListRoute.movieDetails(movie.id)) {
                                MoviePosterCardView(movie: movie)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.plain)
                            .task(id: movie.id) {
                                await viewModel.loadNextPageIfNeeded(
                                    in: section,
                                    currentMovie: movie,
                                    source: .categoryScreen
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 28)
                }
                .scrollIndicators(.hidden)
            } else {
                ContentUnavailableView {
                    Label("No Movies Loaded", systemImage: "film.stack")
                }
                .foregroundStyle(.white)
            }

            if viewModel.isLoadingMore {
                ProgressView("Loading more movies")
                    .tint(.white)
                    .foregroundStyle(.white)
            }
        }
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        MoviesCategoryView(
            category: .topRated,
            viewModel: MoviesListViewModel(movieService: MoviesListPreviewMovieService())
        )
    }
}
