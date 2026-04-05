import SwiftUI
import FamilyControls
import Combine

enum AppState: String, Codable {
    case setup
    case locked
    case runReady
    case running
    case finish
}

@MainActor
class AppViewModel: ObservableObject {

    // MARK: - Published
    @Published var appState: AppState = .setup
    @Published var selection = FamilyActivitySelection()
    @Published var lockHours: Int = 0
    @Published var lockMinutes: Int = 30
    @Published var targetDistance: Double = 1.0
    @Published var remainingSeconds: Int = 0
    @Published var isAuthorized = false

    // MARK: - Private
    private let lockService = LockService()
    private var timerCancellable: AnyCancellable?
    private var lockEndDate: Date?

    private enum Keys {
        static let appState       = "npt_appState"
        static let lockEndDate    = "npt_lockEndDate"
        static let targetDistance = "npt_targetDistance"
        static let selection      = "npt_selection"
    }

    // MARK: - Init
    init() {
        Task {
            await requestAuthorization()
        }
        restoreState()
    }

    // MARK: - Authorization
    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            isAuthorized = true
        } catch {
            isAuthorized = false
            print("FamilyControls authorization failed: \(error)")
        }
    }

    // MARK: - Start Lock
    func startLock() {
        let totalSeconds = lockHours * 3600 + lockMinutes * 60
        guard totalSeconds > 0 else { return }

        lockEndDate = Date().addingTimeInterval(TimeInterval(totalSeconds))
        remainingSeconds = totalSeconds

        lockService.applyLock(selection: selection)
        saveState()

        appState = .locked
        startCountdown()
    }

    // MARK: - Countdown
    private func startCountdown() {
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        guard let endDate = lockEndDate else { return }
        let remaining = Int(endDate.timeIntervalSinceNow)
        if remaining <= 0 {
            timerCancellable?.cancel()
            remainingSeconds = 0
            appState = .runReady
            saveState()
        } else {
            remainingSeconds = remaining
        }
    }

    // MARK: - Running
    func startRunning() {
        appState = .running
    }

    func completeRun() {
        lockService.removeLock()
        appState = .finish
        clearState()
    }

    // MARK: - Reset
    func reset() {
        timerCancellable?.cancel()
        lockService.removeLock()
        appState = .setup
        selection = FamilyActivitySelection()
        lockHours = 0
        lockMinutes = 30
        targetDistance = 1.0
        remainingSeconds = 0
        lockEndDate = nil
        clearState()
    }

    // MARK: - Persistence
    private func saveState() {
        let defaults = UserDefaults.standard
        defaults.set(appState.rawValue, forKey: Keys.appState)
        defaults.set(lockEndDate, forKey: Keys.lockEndDate)
        defaults.set(targetDistance, forKey: Keys.targetDistance)

        if let encoded = try? JSONEncoder().encode(selection) {
            defaults.set(encoded, forKey: Keys.selection)
        }
    }

    private func restoreState() {
        let defaults = UserDefaults.standard
        guard let raw = defaults.string(forKey: Keys.appState),
              let state = AppState(rawValue: raw) else { return }

        targetDistance = defaults.double(forKey: Keys.targetDistance)
        if targetDistance == 0 { targetDistance = 1.0 }

        if let data = defaults.data(forKey: Keys.selection),
           let restored = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            selection = restored
        }

        switch state {
        case .locked:
            if let endDate = defaults.object(forKey: Keys.lockEndDate) as? Date {
                lockEndDate = endDate
                let remaining = Int(endDate.timeIntervalSinceNow)
                if remaining > 0 {
                    remainingSeconds = remaining
                    appState = .locked
                    startCountdown()
                } else {
                    appState = .runReady
                }
            }
        case .runReady:
            appState = .runReady
        case .running:
            // 달리기 도중 앱이 종료됐으면 RunReady부터 다시
            appState = .runReady
        case .setup, .finish:
            break
        }
    }

    private func clearState() {
        let d = UserDefaults.standard
        d.removeObject(forKey: Keys.appState)
        d.removeObject(forKey: Keys.lockEndDate)
        d.removeObject(forKey: Keys.targetDistance)
        d.removeObject(forKey: Keys.selection)
    }

    // MARK: - Helpers
    var formattedRemaining: String {
        let h = remainingSeconds / 3600
        let m = (remainingSeconds % 3600) / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}
