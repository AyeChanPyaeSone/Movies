enum MoviesListTab: String, CaseIterable, Identifiable {
    case home
    case search
    case favorites
    case profile

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .home:
            "Home"
        case .search:
            "Search"
        case .favorites:
            "Favorites"
        case .profile:
            "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .home:
            "house.fill"
        case .search:
            "magnifyingglass"
        case .favorites:
            "heart"
        case .profile:
            "person"
        }
    }
}
