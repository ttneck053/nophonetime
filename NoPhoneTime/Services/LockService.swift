import FamilyControls
import ManagedSettings

class LockService {
    private let store = ManagedSettingsStore()

    func applyLock(selection: FamilyActivitySelection) {
        if !selection.applicationTokens.isEmpty {
            store.shield.applications = selection.applicationTokens
        }
        if !selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = .specific(selection.categoryTokens)
        }
        if !selection.webDomainTokens.isEmpty {
            store.shield.webDomains = selection.webDomainTokens
        }
    }

    func removeLock() {
        store.clearAllSettings()
    }
}
