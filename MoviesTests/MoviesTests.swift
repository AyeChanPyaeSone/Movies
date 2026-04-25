//
//  MoviesTests.swift
//  MoviesTests
//
//  Created by ayechanpyaesone on 25/4/2026.
//

import Foundation
import Testing
import TMDBKit
@testable import Movies

struct MoviesTests {

    @MainActor
    @Test("Initial load stores page results and pagination metadata")
    func initialLoadStoresResultsAndMetadata() async {
        let recorder = PageRequestRecorder()
        let firstPage = makePage(
            page: 1,
            totalPages: 3,
            movies: [
                makeMovie(id: 1),
                makeMovie(id: 2),
            ]
        )
        let viewModel = MoviesViewModel { page in
            await recorder.record(page)
            return firstPage
        }

        await viewModel.loadMovies()

        #expect(viewModel.movies == firstPage.results)
        #expect(viewModel.currentPage == 1)
        #expect(viewModel.totalPages == 3)
        #expect(viewModel.canLoadMore)
        #expect(viewModel.errorMessage == nil)
        #expect(await recorder.snapshot() == [1])
    }

    @MainActor
    @Test("Loading the last visible movie appends the next page once")
    func reachingLastMovieAppendsNextPage() async throws {
        let recorder = PageRequestRecorder()
        let firstPage = makePage(
            page: 1,
            totalPages: 3,
            movies: [
                makeMovie(id: 1),
                makeMovie(id: 2),
            ]
        )
        let secondPage = makePage(
            page: 2,
            totalPages: 3,
            movies: [
                makeMovie(id: 3),
            ]
        )
        let viewModel = MoviesViewModel { page in
            await recorder.record(page)

            switch page {
            case 1:
                return firstPage
            case 2:
                return secondPage
            default:
                Issue.record("Unexpected page requested: \(page)")
                return secondPage
            }
        }

        await viewModel.loadMovies()
        let lastMovie = try #require(viewModel.movies.last)

        await viewModel.loadNextPageIfNeeded(currentMovie: lastMovie)

        #expect(viewModel.movies == firstPage.results + secondPage.results)
        #expect(viewModel.currentPage == 2)
        #expect(viewModel.totalPages == 3)
        #expect(viewModel.canLoadMore)
        #expect(await recorder.snapshot() == [1, 2])
    }

    @MainActor
    @Test("Pagination is ignored while a load is already in flight")
    func noAppendOccursWhileLoading() async throws {
        let recorder = PageRequestRecorder()
        let gate = LoadGate()
        let firstPage = makePage(
            page: 1,
            totalPages: 3,
            movies: [
                makeMovie(id: 1),
            ]
        )
        let secondPage = makePage(
            page: 2,
            totalPages: 3,
            movies: [
                makeMovie(id: 2),
            ]
        )
        let viewModel = MoviesViewModel { page in
            await recorder.record(page)

            switch page {
            case 1:
                return firstPage
            case 2:
                await gate.wait()
                return secondPage
            default:
                Issue.record("Unexpected page requested: \(page)")
                return secondPage
            }
        }

        await viewModel.loadMovies()
        let lastMovie = try #require(viewModel.movies.last)
        let firstAppend = Task {
            await viewModel.loadNextPageIfNeeded(currentMovie: lastMovie)
        }

        await waitUntil {
            await recorder.snapshot().count == 2
        }

        #expect(viewModel.isLoading)
        #expect(viewModel.isLoadingMore)

        await viewModel.loadNextPageIfNeeded(currentMovie: lastMovie)
        await gate.open()
        await firstAppend.value

        #expect(await recorder.snapshot() == [1, 2])
        #expect(viewModel.movies == firstPage.results + secondPage.results)
        #expect(viewModel.currentPage == 2)
    }

    @MainActor
    @Test("Pagination stops at the final page")
    func noAppendOccursOnFinalPage() async throws {
        let recorder = PageRequestRecorder()
        let firstPage = makePage(
            page: 1,
            totalPages: 1,
            movies: [
                makeMovie(id: 1),
            ]
        )
        let viewModel = MoviesViewModel { page in
            await recorder.record(page)
            return firstPage
        }

        await viewModel.loadMovies()
        let lastMovie = try #require(viewModel.movies.last)

        await viewModel.loadNextPageIfNeeded(currentMovie: lastMovie)

        #expect(viewModel.movies == firstPage.results)
        #expect(viewModel.currentPage == 1)
        #expect(viewModel.totalPages == 1)
        #expect(viewModel.canLoadMore == false)
        #expect(await recorder.snapshot() == [1])
    }

    @MainActor
    @Test("Append failures preserve existing movies and page state")
    func appendFailureKeepsExistingMovies() async throws {
        let recorder = PageRequestRecorder()
        let firstPage = makePage(
            page: 1,
            totalPages: 2,
            movies: [
                makeMovie(id: 1),
            ]
        )
        let viewModel = MoviesViewModel { page in
            await recorder.record(page)

            switch page {
            case 1:
                return firstPage
            case 2:
                throw TestError("Next page failed")
            default:
                Issue.record("Unexpected page requested: \(page)")
                return firstPage
            }
        }

        await viewModel.loadMovies()
        let lastMovie = try #require(viewModel.movies.last)

        await viewModel.loadNextPageIfNeeded(currentMovie: lastMovie)

        #expect(viewModel.movies == firstPage.results)
        #expect(viewModel.currentPage == 1)
        #expect(viewModel.totalPages == 2)
        #expect(viewModel.errorMessage == "Next page failed")
        #expect(await recorder.snapshot() == [1, 2])
    }

    @MainActor
    @Test("Refresh failures keep the current movies visible")
    func resetFailureKeepsExistingMovies() async {
        let recorder = PageRequestRecorder()
        let failureSwitch = FailureSwitch()
        let firstPage = makePage(
            page: 1,
            totalPages: 3,
            movies: [
                makeMovie(id: 1),
                makeMovie(id: 2),
            ]
        )
        let viewModel = MoviesViewModel { page in
            await recorder.record(page)

            if await failureSwitch.isEnabled {
                throw TestError("Refresh failed")
            }

            return firstPage
        }

        await viewModel.loadMovies()
        await failureSwitch.enable()
        await viewModel.loadMovies(reset: true)

        #expect(viewModel.movies == firstPage.results)
        #expect(viewModel.currentPage == 1)
        #expect(viewModel.totalPages == 3)
        #expect(viewModel.errorMessage == "Refresh failed")
        #expect(await recorder.snapshot() == [1, 1])
    }
}

private actor PageRequestRecorder {
    private var pages: [Int] = []

    func record(_ page: Int) {
        pages.append(page)
    }

    func snapshot() -> [Int] {
        pages
    }
}

private actor LoadGate {
    private var continuation: CheckedContinuation<Void, Never>?

    func wait() async {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }

    func open() {
        continuation?.resume()
        continuation = nil
    }
}

private actor FailureSwitch {
    private(set) var isEnabled = false

    func enable() {
        isEnabled = true
    }
}

private struct TestError: LocalizedError {
    let errorDescription: String?

    init(_ description: String) {
        errorDescription = description
    }
}

private func waitUntil(
    maxIterations: Int = 200,
    condition: @escaping @Sendable () async -> Bool
) async {
    for _ in 0..<maxIterations {
        if await condition() {
            return
        }

        await Task.yield()
    }

    Issue.record("Timed out waiting for async condition.")
}

private func makePage(page: Int, totalPages: Int, movies: [Movie]) -> MoviePage {
    MoviePage(
        page: page,
        results: movies,
        totalPages: totalPages,
        totalResults: movies.count * totalPages
    )
}

private func makeMovie(id: Int) -> Movie {
    Movie(
        id: id,
        title: "Movie \(id)",
        overview: "Overview \(id)",
        posterPath: nil,
        backdropPath: nil,
        releaseDate: "2026-04-\(String(format: "%02d", id))",
        popularity: Double(id),
        voteAverage: 7.5,
        voteCount: 100 + id
    )
}
