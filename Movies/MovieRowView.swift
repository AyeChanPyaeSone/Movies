import SwiftUI
import TMDBKit

struct MovieRowView: View {
    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(movie.title)
                .font(.headline)

            if let releaseDate = movie.releaseDate, !releaseDate.isEmpty {
                Text(releaseDate)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(movie.overview)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    MovieRowView(
        movie: Movie(
            id: 1,
            title: "Sample Movie",
            overview: "A preview row for checking spacing, typography, and truncation.",
            posterPath: nil,
            backdropPath: nil,
            releaseDate: "2026-04-25",
            popularity: 8.5,
            voteAverage: 7.9,
            voteCount: 120
        )
    )
}
