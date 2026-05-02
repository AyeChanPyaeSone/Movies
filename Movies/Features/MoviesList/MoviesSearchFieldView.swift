import SwiftUI

struct MoviesSearchFieldView: View {
    @Binding var searchText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Discover")
                .font(.title3)
                .bold()
                .foregroundStyle(.white)

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.white.opacity(0.65))

                TextField("Search by title", text: $searchText)
                    .textInputAutocapitalization(.words)
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.3))
            .clipShape(.rect(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(.white.opacity(0.08))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    MoviesSearchFieldView(searchText: .constant(""))
        .padding()
        .background(.black)
}
