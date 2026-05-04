import SwiftUI
import TMDBKit

struct MovieDetailsMetadataView: View {
    let details: MovieDetails
    let directors: [MovieCrewMember]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.title3)
                .bold()
                .foregroundStyle(.white)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 12)], spacing: 12) {
                if let runtimeText = details.runtimeText {
                    MovieDetailsFactView(title: "Runtime", value: runtimeText)
                }

                if !details.genres.isEmpty {
                    MovieDetailsFactView(
                        title: "Genres",
                        value: details.genres.map(\.name).joined(separator: ", ")
                    )
                }

                if !directors.isEmpty {
                    MovieDetailsFactView(
                        title: "Director",
                        value: directors.map(\.name).joined(separator: ", ")
                    )
                }

                if let status = details.status {
                    MovieDetailsFactView(title: "Status", value: status)
                }
            }
        }
    }
}
