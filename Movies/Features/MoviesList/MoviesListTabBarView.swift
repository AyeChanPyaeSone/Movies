import SwiftUI

struct MoviesListTabBarView: View {
    @Binding var selection: MoviesListTab

    var body: some View {
        HStack {
            ForEach(MoviesListTab.allCases) { tab in
                Button(action: {
                    selection = tab
                }) {
                    VStack {
                        Image(systemName: tab.systemImage)
                            .imageScale(.medium)

                        Text(tab.title)
                            .font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(selection == tab ? .white : .white.opacity(0.55))
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(red: 23 / 255, green: 33 / 255, blue: 74 / 255).opacity(0.96))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(height: 1)
        }
    }
}

#Preview {
    MoviesListTabBarView(selection: .constant(.home))
}
