import SwiftUI

struct MovieDetailsHeroView: View {
    let viewModel: MovieDetailsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack(alignment: .bottomLeading) {
                MovieArtworkView(
                    url: viewModel.backdropURL ?? viewModel.posterURL,
                    aspectRatio: 16 / 10,
                    placeholderSystemImage: "film.stack.fill",
                    contentMode: .fill
                )
                .frame(maxWidth: .infinity)

                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.25), Color.black.opacity(0.88)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                HStack(alignment: .bottom, spacing: 16) {
                    MovieArtworkView(
                        url: viewModel.posterURL,
                        aspectRatio: 2 / 3,
                        placeholderSystemImage: "film.fill",
                        contentMode: .fill
                    )
                    .frame(width: 104)
                    .clipShape(.rect(cornerRadius: 16))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(.white.opacity(0.12))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        if let releaseYear = viewModel.releaseYear {
                            MoviesTextBadge(text: releaseYear)
                        }

                        Text(viewModel.title)
                            .font(.title2)
                            .bold()
                            .foregroundStyle(.white)
                            .lineLimit(3)

                        HStack {
                            MoviesRatingBadge(rating: viewModel.rating)

                            Text("\(viewModel.voteCount.formatted(.number)) votes")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.72))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
            .frame(maxWidth: .infinity, minHeight: 280)
            .clipShape(.rect(cornerRadius: 24))
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(.white.opacity(0.08))
            }

            HStack(spacing: 12) {
                if let trailerURL = viewModel.trailerURL {
                    Link(destination: trailerURL) {
                        Label("Trailer", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 54 / 255, green: 114 / 255, blue: 1))
                } else {
                    Button("Trailer", systemImage: "play.fill") {}
                        .buttonStyle(.borderedProminent)
                        .tint(Color(red: 54 / 255, green: 114 / 255, blue: 1))
                        .disabled(true)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}
