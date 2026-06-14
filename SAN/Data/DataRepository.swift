import Foundation

/// Источник данных о заведениях и предложениях.
/// MockDataRepository отдаёт локальные данные. FirebaseDataRepository
/// будет читать те же модели из Firestore — UI не меняется.
protocol DataRepository {
    func fetchVenues() async throws -> [Venue]
    func fetchDeals() async throws -> [Deal]
}

/// Push-уведомления (новые акции рядом / у избранных мест).
protocol PushService {
    func requestAuthorization() async -> Bool
    /// Подписка на темы: "deals_bishkek", "favorites_<venueID>" и т.п.
    func subscribe(topic: String)
    func unsubscribe(topic: String)
}

// MARK: - Mock-реализации (работают сейчас)

final class MockDataRepository: DataRepository {
    func fetchVenues() async throws -> [Venue] { MockData.venues }
    func fetchDeals() async throws -> [Deal] { MockData.deals }
}

final class MockPushService: PushService {
    func requestAuthorization() async -> Bool { true }
    func subscribe(topic: String) { print("[push] subscribe \(topic)") }
    func unsubscribe(topic: String) { print("[push] unsubscribe \(topic)") }
}
