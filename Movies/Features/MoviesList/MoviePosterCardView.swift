import SwiftUI
import TMDBKit

struct MoviePosterCardView: View {
    let movie: Movie

    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topLeading) {
                MovieArtworkView(
                    url: movie.posterURL,
                    aspectRatio: 2 / 3,
                    placeholderSystemImage: "film.fill"
                )

                HStack {
                    if let releaseYear = movie.releaseYear {
                        MoviesTextBadge(text: releaseYear)
                    }

                    MoviesRatingBadge(rating: movie.voteAverage)
                }
                .padding(8)
            }

            Text(movie.title)
                .font(.caption)
                .foregroundStyle(.white)
                .lineLimit(2)

            Text(movie.overview)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.6))
                .lineLimit(2)
        }
        .frame(width: 104)
    }
}

#Preview {
    MoviePosterCardView(movie: MoviesListPreviewMovieService().moviePage.results[0])
}
