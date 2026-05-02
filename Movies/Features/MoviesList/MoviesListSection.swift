import TMDBKit

struct MoviesListSection: Identifiable, Equatable {
    let title: String
    let movies: [Movie]

    var id: String {
        title
    }
}
