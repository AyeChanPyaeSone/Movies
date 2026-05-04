import SwiftUI

struct MovieDetailsBackgroundView: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 7 / 255, green: 11 / 255, blue: 34 / 255),
                Color(red: 9 / 255, green: 18 / 255, blue: 55 / 255),
                Color(red: 17 / 255, green: 26 / 255, blue: 74 / 255)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
