import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: AppViewModel
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            if vm.authorizationFailed {
                AuthDeniedView(message: "설정 > 스크린타임에서\n이 앱의 권한을 허용해주세요.")
            } else {
                switch vm.appState {
                case .setup:    SetupView()
                case .locked:   LockedView()
                case .runReady: RunReadyView()
                case .running:  RunningView()
                case .finish:   FinishView()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.25), value: vm.appState)
        .animation(.easeInOut(duration: 0.25), value: vm.authorizationFailed)
    }
}

struct AuthDeniedView: View {
    let message: String

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 12) {
                    Image(systemName: "lock.slash.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color(.secondaryLabel))

                    VStack(spacing: 6) {
                        Text("권한 필요")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(.label))

                        Text(message)
                            .font(.system(size: 14))
                            .foregroundColor(Color(.secondaryLabel))
                            .multilineTextAlignment(.center)
                    }
                }

                Spacer()

                Button("앱 종료") {
                    exit(0)
                }
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.appYellow)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
    }
}
