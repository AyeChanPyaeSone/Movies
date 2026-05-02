import SwiftUI

struct MoviesRatingBadge: View {
    let rating: Double

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")

            Text(rating, format: .number.precision(.fractionLength(1)))
        }
        .font(.caption2)
        .foregroundStyle(.white)
        .imageScale(.small)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.black.opacity(0.45))
        .clipShape(.capsule)
    }
}
