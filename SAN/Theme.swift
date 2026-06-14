import SwiftUI

/// Тема оформления. Хранится в UserDefaults, применяется на корне приложения.
enum AppTheme: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "Системная"
        case .light: return "Светлая"
        case .dark: return "Тёмная"
        }
    }

    var icon: String {
        switch self {
        case .system: return "iphone"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    /// nil = следовать системе
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

/// Лёгкий стор для темы. Используется на корне и в профиле.
@MainActor
final class ThemeStore: ObservableObject {
    @AppStorage("san.theme") private var raw: String = AppTheme.system.rawValue

    var theme: AppTheme {
        get { AppTheme(rawValue: raw) ?? .system }
        set { raw = newValue.rawValue; objectWillChange.send() }
    }
}
