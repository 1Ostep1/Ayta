import SwiftUI

/// Мок-данные для MVP: заведения Бишкека и их предложения.
/// В проде заменяется на API.
enum MockData {

    private static func days(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: n, to: .now) ?? .now
    }

    // MARK: - Заведения

    static let venues: [Venue] = [
        Venue(id: "navat", name: "Navat", category: .teahouse, district: "Центр",
              address: "пр. Чуй, 125", phone: "+996 312 909 000", emoji: "🫖",
              gradient: [Color(hex: 0xE65C00), Color(hex: 0xF9D423)]),
        Venue(id: "faiza", name: "Faiza", category: .cafe, district: "Восток-5",
              address: "ул. Медерова, 217", phone: "+996 555 919 555", emoji: "🥟",
              gradient: [Color(hex: 0x11998E), Color(hex: 0x38EF7D)]),
        Venue(id: "sierra", name: "Sierra Coffee", category: .coffee, district: "Центр",
              address: "ул. Манаса, 57", phone: "+996 312 311 000", emoji: "☕️",
              gradient: [Color(hex: 0x5D4157), Color(hex: 0xA8CABA)]),
        Venue(id: "bublik", name: "Bublik", category: .bakery, district: "Центр",
              address: "ул. Токтогула, 93", phone: "+996 700 905 905", emoji: "🥐",
              gradient: [Color(hex: 0xF7971E), Color(hex: 0xFFD200)]),
        Venue(id: "furusato", name: "Furusato", category: .restaurant, district: "Центр",
              address: "пр. Эркиндик, 35", phone: "+996 555 750 750", emoji: "🍣",
              gradient: [Color(hex: 0xC31432), Color(hex: 0x240B36)]),
        Venue(id: "chickenstar", name: "Chicken Star", category: .fastfood, district: "Центр",
              address: "пр. Эркиндик, 36", phone: "+996 708 700 007", emoji: "🍗",
              gradient: [Color(hex: 0xF12711), Color(hex: 0xF5AF19)]),
        Venue(id: "cyclone", name: "Cyclone", category: .restaurant, district: "Центр",
              address: "пр. Чуй, 136", phone: "+996 312 621 190", emoji: "🍝",
              gradient: [Color(hex: 0x355C7D), Color(hex: 0xC06C84)]),
        Venue(id: "adriano", name: "Adriano Coffee", category: .coffee, district: "Моссовет",
              address: "ул. Киевская, 77", phone: "+996 702 909 290", emoji: "🍵",
              gradient: [Color(hex: 0x3E5151), Color(hex: 0xDECBA4)]),
        Venue(id: "arzu", name: "Арзу", category: .cafe, district: "Юг-2",
              address: "ул. Горького, 1Б", phone: "+996 312 540 540", emoji: "🍲",
              gradient: [Color(hex: 0x870000), Color(hex: 0x190A05)]),
        Venue(id: "shaurma1", name: "Шаурма №1", category: .fastfood, district: "Аламедин-1",
              address: "ул. Лущихина, 10", phone: "+996 550 100 100", emoji: "🌯",
              gradient: [Color(hex: 0x636FA4), Color(hex: 0xE8CBC0)]),
    ]

    // MARK: - Предложения

    static let deals: [Deal] = [
        Deal(id: "d1", venueID: "navat", type: .discount,
             title: "−30% на манты по будням",
             details: "С 11:00 до 15:00 на все виды мантов. Идеально на обед.",
             emoji: "🥟", oldPrice: 280, newPrice: 195, discountPercent: 30, validUntil: days(12)),
        Deal(id: "d2", venueID: "navat", type: .promo,
             title: "Чайник чая в подарок",
             details: "При заказе от 1500 сом — чайник ташкентского чая бесплатно.",
             emoji: "🫖", oldPrice: nil, newPrice: nil, discountPercent: nil, validUntil: days(6)),
        Deal(id: "d3", venueID: "faiza", type: .discount,
             title: "−20% на лагман",
             details: "Фирменный лагман по будням после 16:00.",
             emoji: "🍜", oldPrice: 320, newPrice: 255, discountPercent: 20, validUntil: days(9)),
        Deal(id: "d4", venueID: "sierra", type: .promo,
             title: "1+1 на капучино",
             details: "Каждое утро до 10:00 — второй капучино бесплатно.",
             emoji: "☕️", oldPrice: nil, newPrice: nil, discountPercent: nil, validUntil: days(20)),
        Deal(id: "d5", venueID: "sierra", type: .novelty,
             title: "Bumble с апельсином",
             details: "Новый летний кофе: эспрессо + свежевыжатый апельсин.",
             emoji: "🍊", oldPrice: nil, newPrice: 290, discountPercent: nil, validUntil: days(25)),
        Deal(id: "d6", venueID: "bublik", type: .discount,
             title: "−50% на выпечку вечером",
             details: "Ежедневно после 20:00 — вся витрина за полцены.",
             emoji: "🥐", oldPrice: nil, newPrice: nil, discountPercent: 50, validUntil: days(30)),
        Deal(id: "d7", venueID: "furusato", type: .novelty,
             title: "Сет «Бишкек» — 24 ролла",
             details: "Новый большой сет: филадельфия, калифорния, запечённые.",
             emoji: "🍣", oldPrice: nil, newPrice: 1890, discountPercent: nil, validUntil: days(18)),
        Deal(id: "d8", venueID: "furusato", type: .discount,
             title: "−15% на всё меню по вторникам",
             details: "Весь день, на зал и самовывоз.",
             emoji: "🍱", oldPrice: nil, newPrice: nil, discountPercent: 15, validUntil: days(14)),
        Deal(id: "d9", venueID: "chickenstar", type: .promo,
             title: "Комбо «Стар» за 390 сом",
             details: "Крылышки + картофель + напиток. Обычная цена 520 сом.",
             emoji: "🍗", oldPrice: 520, newPrice: 390, discountPercent: nil, validUntil: days(8)),
        Deal(id: "d10", venueID: "cyclone", type: .discount,
             title: "−25% на пасту в обед",
             details: "Будни с 12:00 до 15:00, вся паста ручной работы.",
             emoji: "🍝", oldPrice: 480, newPrice: 360, discountPercent: 25, validUntil: days(10)),
        Deal(id: "d11", venueID: "adriano", type: .novelty,
             title: "Матча-латте",
             details: "Японская матча церемониального сорта, на любом молоке.",
             emoji: "🍵", oldPrice: nil, newPrice: 270, discountPercent: nil, validUntil: days(22)),
        Deal(id: "d12", venueID: "adriano", type: .promo,
             title: "Десерт в подарок к кофе",
             details: "С 14:00 до 16:00 — чизкейк или брауни к любому кофе.",
             emoji: "🍰", oldPrice: nil, newPrice: nil, discountPercent: nil, validUntil: days(5)),
        Deal(id: "d13", venueID: "arzu", type: .discount,
             title: "−20% на бешбармак",
             details: "Для компаний от 4 человек, по предзаказу.",
             emoji: "🍲", oldPrice: nil, newPrice: nil, discountPercent: 20, validUntil: days(11)),
        Deal(id: "d14", venueID: "shaurma1", type: .promo,
             title: "Вторая шаурма −50%",
             details: "На классическую и сырную, ежедневно.",
             emoji: "🌯", oldPrice: nil, newPrice: nil, discountPercent: nil, validUntil: days(7)),
        Deal(id: "d15", venueID: "shaurma1", type: .novelty,
             title: "Шаурма с сыром",
             details: "Двойной сыр, фирменный соус. Уже в меню.",
             emoji: "🧀", oldPrice: nil, newPrice: 250, discountPercent: nil, validUntil: days(16)),
    ]

    // MARK: - Выборки

    static func venue(for deal: Deal) -> Venue {
        venues.first { $0.id == deal.venueID } ?? venues[0]
    }

    static func deals(for venue: Venue) -> [Deal] {
        deals.filter { $0.venueID == venue.id && $0.isActive }
    }

    /// Лента: только активные, ближайшие к окончанию выше
    static var activeDeals: [Deal] {
        deals.filter(\.isActive).sorted { $0.validUntil < $1.validUntil }
    }

    static func deal(by id: String) -> Deal? {
        deals.first { $0.id == id }
    }
}
