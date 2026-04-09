import CoreMotion
import Combine

class LocationService: NSObject, ObservableObject {

    // MARK: - Published
    @Published var movedDistance: Double = 0      // km
    @Published var elapsedSeconds: Int = 0
    @Published var isTracking = false
    @Published var authorizationDenied = false

    // MARK: - Computed
    var remainingDistance: Double { max(targetDistance - movedDistance, 0) }

    var paceFormatted: String {
        guard movedDistance > 0.005 else { return "--'--\"" }
        let paceSeconds = Int(Double(elapsedSeconds) / movedDistance)
        let m = paceSeconds / 60
        let s = paceSeconds % 60
        return String(format: "%d'%02d\"", m, s)
    }

    var elapsedFormatted: String {
        let m = elapsedSeconds / 60
        let s = elapsedSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    var progress: Double {
        guard targetDistance > 0 else { return 0 }
        return min(movedDistance / targetDistance, 1.0)
    }

    // MARK: - Internal
    var targetDistance: Double = 1.0

    private let pedometer = CMPedometer()
    private var startTime: Date?
    private var timerCancellable: AnyCancellable?

    // MARK: - Control
    func startTracking(target: Double) {
        guard CMPedometer.isDistanceAvailable() else {
            authorizationDenied = true
            return
        }

        targetDistance = target
        movedDistance = 0
        elapsedSeconds = 0
        startTime = Date()
        isTracking = true

        pedometer.startUpdates(from: startTime!) { [weak self] data, error in
            guard let self, let data, error == nil else { return }
            DispatchQueue.main.async {
                self.movedDistance = (data.distance?.doubleValue ?? 0) / 1000.0
            }
        }

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, let start = self.startTime else { return }
                self.elapsedSeconds = Int(Date().timeIntervalSince(start))
            }
    }

    func stopTracking() {
        pedometer.stopUpdates()
        timerCancellable?.cancel()
        isTracking = false
    }
}
