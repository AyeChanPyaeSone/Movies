import TMDBKit

struct MoviesListSection: Identifiable, Equatable {
    let title: String
    let movies: [Movie]
    let category: MovieListCategory?

    var id: String {
        title
    }
}
