import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: AppViewModel

    var body: some View {
        Group {
            switch vm.appState {
            case .setup:    SetupView()
            case .locked:   LockedView()
            case .runReady: RunReadyView()
            case .running:  RunningView()
            case .finish:   FinishView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: vm.appState)
    }
}
