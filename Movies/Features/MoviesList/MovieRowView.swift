import SwiftUI
import TMDBKit

struct MovieRowView: View {
    let section: MoviesListSection
    let loadMoreAction: (Movie) async -> Void

    var body: some View {
        VStack(alignment: .leading) {
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
                LazyHStack {
                    ForEach(section.movies) { movie in
                        MoviePosterCardView(movie: movie)
                            .task(id: movie.id) {
                                await loadMoreAction(movie)
                            }
                    }
                }
                .padding(.vertical, 4)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.top, 12)
    }
}

#Preview {
    MovieRowView(
        section: MoviesListSection(
            title: "Action",
            movies: MoviesListPreviewMovieService().moviePage.results
        ),
        loadMoreAction: { _ in }
    )
}
