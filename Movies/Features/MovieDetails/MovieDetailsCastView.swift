import SwiftUI
import TMDBKit

struct MovieDetailsCastView: View {
    let cast: [MovieCastMember]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cast")
                .font(.title3)
                .bold()
                .foregroundStyle(.white)

            ScrollView(.horizontal) {
                LazyHStack(spacing: 12) {
                    ForEach(cast) { member in
                        MovieCastMemberView(member: member)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}
