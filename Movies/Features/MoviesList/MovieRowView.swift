import SwiftUI
import TMDBKit

struct MovieRowView: View {
    let section: MoviesListSection
    let loadMoreAction: (MoviesListSection, Movie) async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(section.title)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.white)

                Spacer()

                Text("See all")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.75))
            }

            ScrollView(.horizontal) {
                LazyHStack(spacing: 12) {
                    ForEach(section.movies) { movie in
                        MoviePosterCardView(movie: movie)
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
    MovieRowView(
        section: MoviesListSection(
            title: "Top Rated",
            movies: MoviesListPreviewMovieService().topRatedPage.results,
            category: .topRated
        ),
        loadMoreAction: { _, _ in }
    )
}
