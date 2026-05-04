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

    func fetchPopularMoviesPage(_ page: Int) async throws -> MoviePage {
        moviePage
    }

    func fetchMovieDetails(id: Int) async throws -> MovieDetails {
        let movie = moviePage.results.first { $0.id == id } ?? moviePage.results[0]

        return MovieDetails(
            id: movie.id,
            title: movie.title,
            originalTitle: movie.title,
            overview: movie.overview,
            tagline: "Every story hides a signal.",
            posterPath: movie.posterPath,
            backdropPath: movie.backdropPath,
            releaseDate: movie.releaseDate,
            runtime: 124,
            status: "Released",
            homepage: nil,
            popularity: movie.popularity,
            voteAverage: movie.voteAverage,
            voteCount: movie.voteCount,
            genres: [
                MovieGenre(id: 28, name: "Action"),
                MovieGenre(id: 878, name: "Science Fiction")
            ],
            credits: MovieCredits(
                cast: [
                    MovieCastMember(id: 11, name: "Maya Chen", character: "Nova Vale", profilePath: nil),
                    MovieCastMember(id: 12, name: "Jon Bell", character: "Captain Rowe", profilePath: nil),
                    MovieCastMember(id: 13, name: "Ari Stone", character: "Lyra", profilePath: nil)
                ],
                crew: [
                    MovieCrewMember(
                        id: 21,
                        name: "Rae Coleman",
                        job: "Director",
                        department: "Directing",
                        profilePath: nil
                    )
                ]
            ),
            videos: MovieVideos(
                results: [
                    MovieVideo(
                        id: "preview-trailer",
                        key: "dQw4w9WgXcQ",
                        name: "\(movie.title) Trailer",
                        site: "YouTube",
                        type: "Trailer",
                        official: true
                    )
                ]
            )
        )
    }
}
