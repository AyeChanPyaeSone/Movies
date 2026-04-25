//
//  ContentView.swift
//  Movies
//
//  Created by ayechanpyaesone on 25/4/2026.
//

import SwiftUI
import TMDBKit

struct ContentView: View {
    @State private var viewModel = MoviesViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.movies.isEmpty {
                    ContentUnavailableView {
                        Label("No Movies Loaded", systemImage: "film.stack")
                    } description: {
                        Text("Add your TMDB credential in AppDependencies, then tap Load Movies.")
                    } actions: {
                        Button("Load Movies") {
                            Task {
                                await viewModel.loadMovies()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List(viewModel.movies) { movie in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(movie.title)
                                .font(.headline)

                            if let releaseDate = movie.releaseDate, !releaseDate.isEmpty {
                                Text(releaseDate)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Text(movie.overview)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .lineLimit(3)
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Popular Movies")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(viewModel.isLoading ? "Loading..." : "Load Movies") {
                        Task {
                            await viewModel.loadMovies()
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .alert(
                "Unable to Load Movies",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { isPresented in
                        if !isPresented {
                            viewModel.dismissError()
                        }
                    }
                ),
                actions: {
                    Button("OK", role: .cancel) {}
                },
                message: {
                    Text(viewModel.errorMessage ?? "")
                }
            )
        }
    }
}

#Preview {
    ContentView()
}
