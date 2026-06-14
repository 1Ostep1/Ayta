import SwiftUI

/// Профиль: минимум для MVP — город, настройки пушей, статистика.
struct ProfileView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var bonus: BonusEngine
    @EnvironmentObject private var themeStore: ThemeStore
    @AppStorage("san.notify.discounts") private var notifyDiscounts = true
    @AppStorage("san.notify.favorites") private var notifyFavorites = true

    private var username: String { session.user?.name ?? "Гость" }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.sanAccent, .yellow],
                                                     startPoint: .topLeading,
                                                     endPoint: .bottomTrailing))
                            Text(String(username.prefix(1)))
                                .font(.title.weight(.bold))
                                .foregroundStyle(.white)
                        }
                        .frame(width: 64, height: 64)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(username)
                                .font(.headline)
                            if let email = session.user?.email {
                                Text(email).font(.caption).foregroundStyle(.secondary)
                            }
                            Label("Бишкек", systemImage: "mappin.and.ellipse")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Статистика") {
                    LabeledContent {
                        Text("\(bonus.balance)")
                    } label: {
                        Label("Бонусов", systemImage: "gift.fill")
                    }
                    LabeledContent {
                        Text("\(store.favoriteDeals.count)")
                    } label: {
                        Label("В избранном", systemImage: "heart.fill")
                    }
                    LabeledContent {
                        Text("\(store.activeDeals.count)")
                    } label: {
                        Label("Активных САН в городе", systemImage: "flame.fill")
                    }
                }

                Section("Оформление") {
                    Picker(selection: Binding(
                        get: { themeStore.theme },
                        set: { themeStore.theme = $0 }
                    )) {
                        ForEach(AppTheme.allCases) { theme in
                            Label(theme.title, systemImage: theme.icon).tag(theme)
                        }
                    } label: {
                        Label("Тема", systemImage: "circle.lefthalf.filled")
                    }
                    .pickerStyle(.menu)
                }

                Section("Уведомления") {
                    Toggle(isOn: $notifyDiscounts) {
                        Label("Новые скидки рядом", systemImage: "percent")
                    }
                    Toggle(isOn: $notifyFavorites) {
                        Label("Акции любимых мест", systemImage: "heart.text.square")
                    }
                }

                Section("О приложении") {
                    LabeledContent("Версия", value: "0.1 (MVP)")
                    Text("САН — скидки, акции и новинки заведений твоего города. Сначала общепит, дальше больше.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section {
                    Button(role: .destructive) {
                        session.signOut()
                    } label: {
                        Label("Выйти", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Профиль")
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppStore())
        .environmentObject(SessionStore())
        .environmentObject(BonusEngine())
        .environmentObject(ThemeStore())
        .tint(.sanAccent)
}
