import SwiftUI
import TMDBKit

struct MovieRowView: View {
    let section: MoviesListSection
    let loadMoreAction: (Movie) async -> Void

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
                        NavigationLink(value: movie.id) {
                            MoviePosterCardView(movie: movie)
                        }
                        .buttonStyle(.plain)
                        .task(id: movie.id) {
                            await loadMoreAction(movie)
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
                title: "Action",
                movies: MoviesListPreviewMovieService().moviePage.results
            ),
            loadMoreAction: { _ in }
        )
    }
}
