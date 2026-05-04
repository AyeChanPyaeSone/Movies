import SwiftUI
import TMDBKit

struct MovieDetailsOverviewView: View {
    let viewModel: MovieDetailsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let tagline = viewModel.details?.tagline, !tagline.isEmpty {
                Text(tagline)
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            Text("Overview")
                .font(.title3)
                .bold()
                .foregroundStyle(.white)

            Text(viewModel.overview)
                .font(.body)
                .foregroundStyle(.white.opacity(0.78))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
