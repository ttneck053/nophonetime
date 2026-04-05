import CoreLocation
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
        guard movedDistance > 0.05 else { return "--'--\"" }
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

    private let manager = CLLocationManager()
    private var lastLocation: CLLocation?
    private var startTime: Date?
    private var timerCancellable: AnyCancellable?

    // MARK: - Init
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 5
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        manager.activityType = .fitness
    }

    // MARK: - Control
    func startTracking(target: Double) {
        targetDistance = target
        movedDistance = 0
        elapsedSeconds = 0
        lastLocation = nil
        startTime = Date()
        isTracking = true

        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, let start = self.startTime else { return }
                self.elapsedSeconds = Int(Date().timeIntervalSince(start))
            }
    }

    func stopTracking() {
        manager.stopUpdatingLocation()
        timerCancellable?.cancel()
        isTracking = false
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last,
              location.horizontalAccuracy > 0,
              location.horizontalAccuracy < 30 else { return }

        if let last = lastLocation {
            let delta = location.distance(from: last) / 1000.0
            // 비정상적인 GPS 점프 무시 (100m 이상)
            if delta < 0.1 {
                movedDistance += delta
            }
        }
        lastLocation = location
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationService error: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied, .restricted:
            authorizationDenied = true
        default:
            authorizationDenied = false
        }
    }
}
