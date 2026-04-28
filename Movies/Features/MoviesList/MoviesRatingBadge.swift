import SwiftUI

struct MoviesRatingBadge: View {
    let rating: Double

    var body: some View {
        Label {
            Text(rating, format: .number.precision(.fractionLength(1)))
        } icon: {
            Image(systemName: "star.fill")
        }
        .font(.caption2)
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.black.opacity(0.45))
        .clipShape(.capsule)
    }
}
