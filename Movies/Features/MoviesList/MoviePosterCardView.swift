import SwiftUI
import TMDBKit

struct MoviePosterCardView: View {
    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                MovieArtworkView(
                    url: movie.posterURL,
                    aspectRatio: 2 / 3,
                    placeholderSystemImage: "film.fill"
                )

                HStack {
                    MoviesRatingBadge(rating: movie.voteAverage)
                }
                .padding(8)
            }

            Text(movie.title)
                .font(.caption)
                .foregroundStyle(.white)
                .lineLimit(1)

            Text(movie.overview)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.6))
                .lineLimit(2)
        }
        .frame(width: 96)
    }
}

#Preview {
    MoviePosterCardView(movie: MoviesListPreviewMovieService().moviePage.results[0])
}
