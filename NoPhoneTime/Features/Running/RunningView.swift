import SwiftUI

struct RunningView: View {
    @EnvironmentObject var vm: AppViewModel
    @StateObject private var location = LocationService()

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // MARK: 시간 / 페이스
            HStack {
                metricBlock(value: location.elapsedFormatted, label: "시간")
                Spacer()
                metricBlock(value: location.paceFormatted, label: "페이스")
            }
            .padding(.horizontal, 44)

            Spacer().frame(height: 40)

            // MARK: 목표
            statRow(
                value: String(format: "%.2f", vm.targetDistance),
                label: "목표(km)",
                size: 64
            )

            Spacer().frame(height: 16)

            // MARK: 움직인 / 남은
            statRow(
                value: String(format: "%.2f", location.movedDistance),
                label: "움직인 거리(km)",
                size: 44
            )

            Spacer().frame(height: 8)

            statRow(
                value: String(format: "%.2f", location.remainingDistance),
                label: "남은 거리(km)",
                size: 44
            )

            Spacer().frame(height: 48)

            // MARK: 프로그레스 바
            ProgressBar(progress: location.progress)
                .padding(.horizontal, 32)

            Spacer()
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            location.startTracking(target: vm.targetDistance)
        }
        .onDisappear {
            location.stopTracking()
        }
        .onChange(of: location.movedDistance) { _, newValue in
            if newValue >= vm.targetDistance {
                location.stopTracking()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    vm.completeRun()
                }
            }
        }
        .alert("위치 권한이 필요합니다", isPresented: $location.authorizationDenied) {
            Button("설정 열기") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("취소", role: .cancel) { vm.appState = .runReady }
        } message: {
            Text("달리기 추적을 위해 위치 권한(항상 허용)이 필요합니다.")
        }
    }

    private func metricBlock(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 32, weight: .black, design: .rounded))
                .monospacedDigit()
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray)
        }
    }

    private func statRow(value: String, label: String, size: CGFloat) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: size, weight: .black, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.linear(duration: 0.3), value: value)
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Progress Bar
private struct ProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // 배경 (검정)
                Capsule()
                    .fill(Color.black)
                    .frame(height: 12)

                // 진행 (노랑)
                Capsule()
                    .fill(Color.appYellow)
                    .frame(width: max(geo.size.width * progress, 12), height: 12)

                // 달리기 이모지
                Text("🏃")
                    .font(.system(size: 22))
                    .offset(
                        x: max(geo.size.width * progress - 14, 0),
                        y: -18
                    )

                // 체크포인트 깃발
                Text("🏁")
                    .font(.system(size: 22))
                    .offset(x: geo.size.width - 18, y: -18)
            }
        }
        .frame(height: 40)
        .padding(.vertical, 8)
    }
}
