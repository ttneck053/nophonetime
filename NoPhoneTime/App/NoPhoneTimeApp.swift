import SwiftUI
import FamilyControls

@main
struct NoPhoneTimeApp: App {
    @StateObject private var viewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .preferredColorScheme(.light)
        }
    }
}
