import SwiftUI
import TMDBKit

struct MoviesHeroCardView: View {
    let movie: Movie
    let playAction: () -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            MovieArtworkView(
                url: movie.backdropURL ?? movie.posterURL,
                aspectRatio: 16 / 10,
                placeholderSystemImage: "film.stack.fill"
            )

            LinearGradient(
                colors: [.clear, Color.black.opacity(0.2), Color.black.opacity(0.82)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading) {
                HStack {
                    if let releaseYear = movie.releaseYear {
                        MoviesTextBadge(text: releaseYear)
                    }

                    MoviesRatingBadge(rating: movie.voteAverage)
                }

                Spacer()

                Text(movie.title)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Text(movie.overview)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.84))
                    .lineLimit(3)

                HStack {
                    Button("Play Now", systemImage: "play.fill", action: playAction)
                        .buttonStyle(.borderedProminent)
                        .tint(Color(red: 54 / 255, green: 114 / 255, blue: 1))

                    Spacer()

                    Button("Save", systemImage: "plus") {}
                        .buttonStyle(.bordered)
                        .tint(.white)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipShape(.rect(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(.white.opacity(0.08))
        }
    }
}

#Preview {
    MoviesHeroCardView(
        movie: MoviesListPreviewMovieService().moviePage.results[0],
        playAction: {}
    )
}
