import SwiftUI

@main
struct MoviesApp: App {
    init() {
        SentryConfiguration.start()
    }

    private let container = AppContainer.live

    var body: some Scene {
        WindowGroup {
            MoviesListView(movieService: container.movieService)
        }
    }
}
