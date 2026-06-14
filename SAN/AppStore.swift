import SwiftUI

/// Глобальное состояние приложения.
@MainActor
final class AppStore: ObservableObject {

    // MARK: - Live data from repository
    @Published var venues: [Venue] = []
    @Published var deals: [Deal] = []
    @Published var isLoading = false
    @Published var loadError: String?

    private let repository: DataRepository = AppConfig.makeDataRepository()

    func load() async {
        isLoading = true
        loadError = nil
        do {
            async let v = repository.fetchVenues()
            async let d = repository.fetchDeals()
            (venues, deals) = try await (v, d)
        } catch {
            loadError = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Computed helpers

    var activeDeals: [Deal] {
        deals.filter(\.isActive).sorted { $0.validUntil < $1.validUntil }
    }

    func deals(for venue: Venue) -> [Deal] {
        deals.filter { $0.venueID == venue.id && $0.isActive }
    }

    func venue(for deal: Deal) -> Venue? {
        venues.first { $0.id == deal.venueID }
    }

    // MARK: - Favourites (UserDefaults)

    @Published var favoriteDealIDs: Set<String> {
        didSet { UserDefaults.standard.set(Array(favoriteDealIDs), forKey: Self.key) }
    }

    private static let key = "san.favorites"

    init() {
        favoriteDealIDs = Set(UserDefaults.standard.stringArray(forKey: Self.key) ?? [])
    }

    var favoriteDeals: [Deal] {
        favoriteDealIDs
            .compactMap { id in deals.first { $0.id == id } }
            .filter(\.isActive)
            .sorted { $0.validUntil < $1.validUntil }
    }

    func isFavorite(_ deal: Deal) -> Bool {
        favoriteDealIDs.contains(deal.id)
    }

    func toggleFavorite(_ deal: Deal) {
        if favoriteDealIDs.contains(deal.id) {
            favoriteDealIDs.remove(deal.id)
        } else {
            favoriteDealIDs.insert(deal.id)
        }
    }
}
