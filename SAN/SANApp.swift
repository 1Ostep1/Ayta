import SwiftUI
import FirebaseCore
#if canImport(GoogleSignIn)
import GoogleSignIn
#endif

@main
struct SANApp: App {
    init() {
        // Инициализация Firebase. Безопасно вызывать всегда —
        // фактически сервисы используются только при AppConfig.useFirebase = true.
        if AppConfig.useFirebase {
            FirebaseApp.configure()
        }
    }

    @StateObject private var store = AppStore()
    @StateObject private var session = SessionStore()
    @StateObject private var bonus = BonusEngine()
    @StateObject private var themeStore = ThemeStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            Group {
                if session.isSignedIn {
                    RootView()
                } else {
                    AuthView()
                }
            }
            .environmentObject(store)
            .environmentObject(session)
            .environmentObject(bonus)
            .environmentObject(themeStore)
            .tint(.sanAccent)
            .preferredColorScheme(themeStore.theme.colorScheme)
            .onOpenURL { url in
                #if canImport(GoogleSignIn)
                GIDSignIn.sharedInstance.handle(url)
                #endif
            }
            // Любой тап продлевает «активность» для бонус-движка
            .simultaneousGesture(
                TapGesture().onEnded { bonus.registerInteraction() }
            )
            .onChange(of: scenePhase) { _, phase in
                switch phase {
                case .active:
                    if session.isSignedIn { bonus.start() }
                    NotificationManager.refresh(reachedGoalToday: bonus.reachedGoalToday)
                default:
                    bonus.pause()
                }
            }
            .onChange(of: session.isSignedIn) { _, signedIn in
                if signedIn { bonus.start() } else { bonus.pause() }
            }
            // Напоминания о бонусе: разрешение + первичная настройка
            .task {
                await store.load()
                await NotificationManager.requestAuthorization()
                NotificationManager.refresh(reachedGoalToday: bonus.reachedGoalToday)
            }
            // Как только цель за день достигнута — снимаем напоминания
            .onChange(of: bonus.reachedGoalToday) { _, reached in
                NotificationManager.refresh(reachedGoalToday: reached)
            }
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var bonus: BonusEngine

    var body: some View {
        TabView {
            HomeFeedView()
                .tabItem { Label("Главная", systemImage: "house.fill") }
            SearchView()
                .tabItem { Label("Поиск", systemImage: "magnifyingglass") }
            BonusHubView()
                .tabItem { Label("Бонусы", systemImage: "gift.fill") }
            FavoritesView()
                .tabItem { Label("Избранное", systemImage: "heart.fill") }
            ProfileView()
                .tabItem { Label("Профиль", systemImage: "person.fill") }
        }
        // Скролл/жесты по всему приложению считаются взаимодействием
        .simultaneousGesture(
            DragGesture(minimumDistance: 1)
                .onChanged { _ in bonus.registerInteraction() }
        )
    }
}

#Preview {
    RootView()
        .environmentObject(AppStore())
        .environmentObject(SessionStore())
        .environmentObject(BonusEngine())
        .tint(.sanAccent)
}
