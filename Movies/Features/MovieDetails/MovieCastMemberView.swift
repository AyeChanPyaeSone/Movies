import SwiftUI
import TMDBKit

struct MovieCastMemberView: View {
    let member: MovieCastMember

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            MovieArtworkView(
                url: member.profileURL,
                aspectRatio: 2 / 3,
                placeholderSystemImage: "person.fill",
                contentMode: .fill
            )
            .frame(width: 88)
            .clipShape(.rect(cornerRadius: 14))

            Text(member.name)
                .font(.caption)
                .foregroundStyle(.white)
                .lineLimit(2)

            if let character = member.character, !character.isEmpty {
                Text(character)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.58))
                    .lineLimit(2)
            }
        }
        .frame(width: 88, alignment: .topLeading)
    }
}
