import SwiftUI

struct MovieArtworkView: View {
    let url: URL?
    let aspectRatio: CGFloat
    let placeholderSystemImage: String

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
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
        .aspectRatio(aspectRatio, contentMode: .fill)
        .clipped()
    }
}

#Preview {
    MovieArtworkView(url: nil, aspectRatio: 2 / 3, placeholderSystemImage: "film.fill")
        .padding()
        .background(.black)
}
