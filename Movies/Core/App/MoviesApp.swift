import SwiftUI

@main
struct MoviesApp: App {
    private let container = AppContainer.live

    var body: some Scene {
        WindowGroup {
            MoviesListView(movieService: container.movieService)
        }
    }
}
