import SwiftUI
import TMDBKit

struct MovieRowView: View {
    let section: MoviesListSection
    let categoryAction: (MovieListCategory) -> Void
    let loadMoreAction: (MoviesListSection, Movie) async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(section.title)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.white)

                Spacer()

                if let category = section.category {
                    Button("See all", systemImage: "chevron.right") {
                        categoryAction(category)
                    }
                    .font(.caption)
                    .labelStyle(.titleAndIcon)
                    .foregroundStyle(.white.opacity(0.75))
                }
            }

            ScrollView(.horizontal) {
                LazyHStack(spacing: 12) {
                    ForEach(section.movies) { movie in
                        NavigationLink(value: MoviesListRoute.movieDetails(movie.id)) {
                            MoviePosterCardView(movie: movie)
                        }
                        .buttonStyle(.plain)
                        .task(id: movie.id) {
                            await loadMoreAction(section, movie)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        MovieRowView(
            section: MoviesListSection(
                title: "Top Rated",
                movies: MoviesListPreviewMovieService().topRatedPage.results,
                category: .topRated
            ),
            categoryAction: { _ in },
            loadMoreAction: { _, _ in }
        )
    }
}
