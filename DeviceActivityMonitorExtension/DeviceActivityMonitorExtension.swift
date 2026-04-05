import DeviceActivity
import ManagedSettings
import FamilyControls

// 이 Extension은 DeviceActivity 스케줄 이벤트를 처리합니다.
// 현재 구현에서는 앱 내 Timer로 잠금 해제를 처리하므로
// 추후 더 정교한 스케줄링이 필요할 때 확장합니다.

class DeviceActivityMonitorExtension: DeviceActivityMonitor {

    private let store = ManagedSettingsStore()

    // 스케줄 시작 시 호출 (잠금 적용)
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
    }

    // 스케줄 종료 시 호출 (잠금 해제 가능 상태로 전환)
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        // 달리기 조건이 있으므로 여기서 직접 해제하지 않음
        // 달리기 완료 후 앱에서 clearAllSettings() 호출
    }

    // 이벤트 발생 시 호출
    override func eventDidReachThreshold(
        _ event: DeviceActivityEvent.Name,
        activity: DeviceActivityName
    ) {
        super.eventDidReachThreshold(event, activity: activity)
    }
}
