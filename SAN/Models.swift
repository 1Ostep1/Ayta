import SwiftUI

// MARK: - Типы предложений (С-А-Н)

enum DealType: String, CaseIterable, Identifiable {
    case discount = "Скидка"
    case promo = "Акция"
    case novelty = "Новинка"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .discount: return .sanAccent
        case .promo: return .purple
        case .novelty: return .teal
        }
    }

    var icon: String {
        switch self {
        case .discount: return "percent"
        case .promo: return "gift.fill"
        case .novelty: return "sparkles"
        }
    }
}

// MARK: - Категории заведений (MVP: только общепит)

enum VenueCategory: String, CaseIterable, Identifiable {
    case cafe = "Кафе"
    case coffee = "Кофейня"
    case fastfood = "Фастфуд"
    case restaurant = "Ресторан"
    case teahouse = "Чайхана"
    case bakery = "Пекарня"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .cafe: return "fork.knife"
        case .coffee: return "cup.and.saucer.fill"
        case .fastfood: return "takeoutbag.and.cup.and.straw.fill"
        case .restaurant: return "wineglass.fill"
        case .teahouse: return "mug.fill"
        case .bakery: return "birthday.cake.fill"
        }
    }
}

// MARK: - Заведение

struct Venue: Identifiable, Hashable {
    let id: String
    let name: String
    let category: VenueCategory
    let district: String
    let address: String
    let phone: String
    let emoji: String
    let gradient: [Color]
}

// MARK: - Предложение

struct Deal: Identifiable, Hashable {
    let id: String
    let venueID: String
    let type: DealType
    let title: String
    let details: String
    let emoji: String
    let oldPrice: Int?
    let newPrice: Int?
    let discountPercent: Int?
    let validUntil: Date

    /// Протухшие акции автоматически скрываются из ленты
    var isActive: Bool { validUntil >= .now }
}

// MARK: - Хелперы

extension Color {
    static let sanAccent = Color(red: 1.0, green: 0.30, blue: 0.16)

    init(hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

extension Date {
    /// «15 июня»
    var sanShort: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "d MMMM"
        return f.string(from: self)
    }
}

extension Int {
    var som: String { "\(self) сом" }
}
