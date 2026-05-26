import TMDBKit

enum MoviesListRoute: Hashable {
    case movieDetails(Int)
    case category(MovieListCategory)
}
