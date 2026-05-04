import SwiftUI
import TMDBKit

struct MovieDetailsView: View {
    @State private var viewModel: MovieDetailsViewModel
    @State private var isShowingError = false

    init(movieID: Int, initialMovie: Movie?, movieService: any MovieService) {
        _viewModel = State(
            initialValue: MovieDetailsViewModel(
                movieID: movieID,
                initialMovie: initialMovie,
                movieService: movieService
            )
        )
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        ZStack {
            MovieDetailsBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    MovieDetailsHeroView(viewModel: viewModel)

                    MovieDetailsOverviewView(viewModel: viewModel)

                    if !viewModel.cast.isEmpty {
                        MovieDetailsCastView(cast: viewModel.cast)
                    }

                    if let details = viewModel.details {
                        MovieDetailsMetadataView(details: details, directors: viewModel.directors)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 28)
            }
            .scrollIndicators(.hidden)

            if viewModel.isLoading && viewModel.details == nil {
                ProgressView("Loading Details")
                    .tint(.white)
                    .foregroundStyle(.white)
            }
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await viewModel.loadDetailsIfNeeded()
        }
        .onChange(of: viewModel.errorMessage) { _, newValue in
            isShowingError = newValue != nil
        }
        .alert(
            "Unable to Load Details",
            isPresented: $isShowingError,
            actions: {
                Button("Retry", action: retryDetails)
                Button("OK", role: .cancel, action: viewModel.dismissError)
            },
            message: {
                Text(viewModel.errorMessage ?? "")
            }
        )
    }

    private func retryDetails() {
        Task {
            await viewModel.loadDetails()
        }
    }
}

#Preview {
    NavigationStack {
        MovieDetailsView(
            movieID: 1,
            initialMovie: MoviesListPreviewMovieService().nowPlayingPage.results[0],
            movieService: MoviesListPreviewMovieService()
        )
    }
}
