import SwiftUI

struct MovieArtworkView: View {
    let url: URL?
    let aspectRatio: CGFloat
    let placeholderSystemImage: String
    let contentMode: ContentMode

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                artworkImage(image)
            case .empty:
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(red: 33 / 255, green: 49 / 255, blue: 105 / 255),
                            Color(red: 16 / 255, green: 24 / 255, blue: 62 / 255)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    ProgressView()
                        .tint(.white.opacity(0.8))
                }
            case .failure:
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(red: 33 / 255, green: 49 / 255, blue: 105 / 255),
                            Color(red: 16 / 255, green: 24 / 255, blue: 62 / 255)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    Image(systemName: placeholderSystemImage)
                        .font(.largeTitle)
                        .foregroundStyle(.white.opacity(0.75))
                }
            @unknown default:
                Color.clear
            }
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipped()
    }

    @ViewBuilder
    private func artworkImage(_ image: Image) -> some View {
        switch contentMode {
        case .fill:
            image
                .resizable()
                .scaledToFill()
        case .fit:
            image
                .resizable()
                .scaledToFit()
        @unknown default:
            image
                .resizable()
                .scaledToFill()
        }
    }
}

#Preview {
    MovieArtworkView(
        url: nil,
        aspectRatio: 2 / 3,
        placeholderSystemImage: "film.fill",
        contentMode: .fill
    )
        .padding()
        .background(.black)
}
