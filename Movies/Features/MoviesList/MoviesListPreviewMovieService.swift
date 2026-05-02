import TMDBKit

struct MoviesListPreviewMovieService: MovieService {
    let moviePage = MoviePage(
        page: 1,
        results: [
            Movie(
                id: 1,
                title: "Stellar Odyssey",
                overview: "A drifting pilot discovers a hidden colony at the edge of the solar system.",
                posterPath: nil,
                backdropPath: nil,
                releaseDate: "2026-04-27",
                popularity: 9.4,
                voteAverage: 8.7,
                voteCount: 1280
            ),
            Movie(
                id: 2,
                title: "Midnight Signal",
                overview: "A courier intercepts a broadcast that changes the fate of an entire city.",
                posterPath: nil,
                backdropPath: nil,
                releaseDate: "2025-10-01",
                popularity: 8.8,
                voteAverage: 7.8,
                voteCount: 900
            ),
            Movie(
                id: 3,
                title: "Velvet Heist",
                overview: "An elegant thief pulls one last impossible job across Europe.",
                posterPath: nil,
                backdropPath: nil,
                releaseDate: "2024-08-14",
                popularity: 8.2,
                voteAverage: 7.5,
                voteCount: 760
            ),
            Movie(
                id: 4,
                title: "Neon Harbor",
                overview: "A detective and a hacker chase a vanished cargo ship through a rain-soaked port.",
                posterPath: nil,
                backdropPath: nil,
                releaseDate: "2025-02-22",
                popularity: 8.5,
                voteAverage: 7.9,
                voteCount: 610
            ),
            Movie(
                id: 5,
                title: "Afterlight",
                overview: "A grieving photographer learns that her prints reveal moments from the future.",
                posterPath: nil,
                backdropPath: nil,
                releaseDate: "2023-11-09",
                popularity: 7.9,
                voteAverage: 7.2,
                voteCount: 544
            ),
            Movie(
                id: 6,
                title: "Circuit Breakers",
                overview: "Teen inventors race to stop a rogue system before the finals begin.",
                posterPath: nil,
                backdropPath: nil,
                releaseDate: "2026-01-18",
                popularity: 8.0,
                voteAverage: 7.4,
                voteCount: 301
            )
        ],
        totalPages: 1,
        totalResults: 6
    )

    func fetchMoviesPage(in category: MovieListCategory, page: Int) async throws -> MoviePage {
        moviePage
    }
}
