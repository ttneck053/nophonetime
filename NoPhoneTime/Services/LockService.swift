import FamilyControls
import ManagedSettings

class LockService {
    private let store = ManagedSettingsStore()

    func applyLock(selection: FamilyActivitySelection) {
        if !selection.applications.isEmpty {
            store.shield.applications = selection.applications
        }
        if !selection.categories.isEmpty {
            store.shield.applicationCategories = .specific(selection.categories)
        }
        if !selection.webDomains.isEmpty {
            store.shield.webDomains = selection.webDomains
        }
        if !selection.webDomainCategories.isEmpty {
            store.shield.webDomainCategories = .specific(selection.webDomainCategories)
        }
    }

    func removeLock() {
        store.clearAllSettings()
    }
}
