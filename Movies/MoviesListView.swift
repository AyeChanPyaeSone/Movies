//
//  ContentView.swift
//  Movies
//
//  Created by ayechanpyaesone on 25/4/2026.
//

import SwiftUI
import TMDBKit

struct MoviesListView: View {
    private enum ScrollTarget {
        static let top = "movies-list-top"
    }

    @State private var viewModel = MoviesListViewModel()

    var body: some View {
        ScrollViewReader { proxy in
            NavigationStack {
                List {
                    Color.clear
                        .frame(height: 0)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .id(ScrollTarget.top)

                    ForEach(viewModel.movies) { movie in
                        MovieRowView(movie: movie)
                            .onAppear {
                                Task {
                                    await viewModel.loadNextPageIfNeeded(currentMovie: movie)
                                }
                            }
                    }

                    if viewModel.isLoadingMore {
                        HStack {
                            Spacer()
                            ProgressView("Loading more movies")
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .onAppear {
                    Task {
                        await viewModel.loadMovies(reset: true)
                    }
                }
                .navigationTitle("Popular Movies")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(viewModel.isLoading ? "Loading..." : toolbarButtonTitle) {
                            if viewModel.movies.isEmpty {
                                Task {
                                    await viewModel.loadMovies(reset: true)
                                }
                            } else {
                                withAnimation {
                                    proxy.scrollTo(ScrollTarget.top, anchor: .top)
                                }
                            }
                        }
                        .disabled(viewModel.isLoading && viewModel.movies.isEmpty)
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

    private var toolbarButtonTitle: String {
        viewModel.movies.isEmpty ? "Load Movies" : "Top"
    }
}

#Preview {
    MoviesListView()
}
