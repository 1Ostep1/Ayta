import SwiftUI

/// Начисляет бонусы за АКТИВНОЕ время в приложении.
///
/// Логика «активные 30 минут»:
/// - секунда засчитывается только если приложение на переднем плане
///   И пользователь взаимодействовал недавно (тап/скролл за последние `idleTimeout` сек);
/// - простой (открыл и отложил телефон) не копит время;
/// - за каждые `goalSeconds` активного времени — начисление `rewardPerGoal` бонусов.
/// Баланс и прогресс сохраняются между запусками.
@MainActor
final class BonusEngine: ObservableObject {

    // Настройки
    let goalSeconds: Int = 30 * 60          // цель: 30 минут
    let rewardPerGoal: Int = 50             // бонусов за цикл
    private let idleTimeout: TimeInterval = 25  // сек без действий = простой

    // Состояние (персистентное)
    @AppStorage("san.bonus.balance") var balance: Int = 0
    @AppStorage("san.bonus.activeSeconds") private var storedActive: Int = 0
    @AppStorage("san.bonus.cycles") var completedCycles: Int = 0
    @AppStorage("san.bonus.lastAwardAt") private var lastAwardAt: Double = 0

    @Published var activeSeconds: Int = 0
    @Published var isCounting = false
    @Published var lastReward: Int? = nil   // для анимации «+50»

    private var lastInteraction = Date()
    private var timer: Timer?

    init() {
        activeSeconds = storedActive
    }

    var progress: Double { Double(activeSeconds) / Double(goalSeconds) }

    /// Получил ли пользователь бонус за 30 минут сегодня.
    /// Если нет — шлём напоминания каждые 4 часа.
    var reachedGoalToday: Bool {
        lastAwardAt > 0 &&
        Calendar.current.isDateInToday(Date(timeIntervalSince1970: lastAwardAt))
    }

    var remaining: String {
        let left = max(0, goalSeconds - activeSeconds)
        return String(format: "%02d:%02d", left / 60, left % 60)
    }

    // Любое взаимодействие продлевает «активность»
    func registerInteraction() {
        lastInteraction = Date()
    }

    func start() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    func pause() {
        timer?.invalidate()
        timer = nil
        isCounting = false
        storedActive = activeSeconds
    }

    private func tick() {
        let active = Date().timeIntervalSince(lastInteraction) < idleTimeout
        isCounting = active
        guard active else { return }

        activeSeconds += 1
        if activeSeconds >= goalSeconds {
            award()
        }
        if activeSeconds % 15 == 0 { storedActive = activeSeconds }   // периодически сохраняем
    }

    private func award() {
        balance += rewardPerGoal
        completedCycles += 1
        activeSeconds = 0
        storedActive = 0
        lastReward = rewardPerGoal
        lastAwardAt = Date().timeIntervalSince1970
        // имитация лёгкой вибрации
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        // цель достигнута — снимаем напоминания на сегодня
        NotificationManager.refresh(reachedGoalToday: true)
    }

    // Игры тоже дают бонусы
    func addFromGame(_ amount: Int) {
        guard amount > 0 else { return }
        balance += amount
        lastReward = amount
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func spend(_ amount: Int) -> Bool {
        guard balance >= amount else { return false }
        balance -= amount
        return true
    }

    func clearRewardFlag() { lastReward = nil }
}
