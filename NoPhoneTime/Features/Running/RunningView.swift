import SwiftUI

struct RunningView: View {
    @EnvironmentObject var vm: AppViewModel
    @StateObject private var location = LocationService()

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: 상단 메트릭 (시간 / 페이스)
                HStack {
                    metricBlock(value: location.elapsedFormatted, label: "시간", alignment: .leading)
                    Spacer()
                    metricBlock(value: location.paceFormatted, label: "페이스", alignment: .trailing)
                }
                .padding(.horizontal, 28)
                .padding(.top, 24)

                Spacer()

                // MARK: 거리 메트릭
                VStack(spacing: 20) {
                    distanceRow(label: "목표", km: vm.targetDistance, size: 36, color: Color(.secondaryLabel))
                    distanceRow(label: "이동", km: location.movedDistance, size: 48, color: Color(.label))
                    distanceRow(label: "남은", km: location.remainingDistance, size: 36, color: .appPink)
                }

                Spacer()

                // MARK: 프로그레스 바
                ProgressBar(progress: location.progress)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 32)
            }
        }
        .onAppear {
            location.startTracking(target: vm.targetDistance)
        }
        .onDisappear {
            location.stopTracking()
        }
        .onChange(of: location.movedDistance) { newValue in
            if newValue >= vm.targetDistance {
                location.stopTracking()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    vm.completeRun()
                }
            }
        }
        .onChange(of: vm.authorizationFailed) { failed in
            if failed { location.stopTracking() }
        }
        .alert("동작 권한이 필요합니다", isPresented: $location.authorizationDenied) {
            Button("설정 열기") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("취소", role: .cancel) { vm.appState = .runReady }
        } message: {
            Text("거리 측정을 위해 동작 권한이 필요합니다.")
        }
    }

    private func metricBlock(value: String, label: String, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: 2) {
            Text(value)
                .font(.system(size: 26, weight: .black, design: .rounded))
                .monospacedDigit()
                .foregroundColor(Color(.label))
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(.secondaryLabel))
        }
    }

    private func distanceRow(label: String, km: Double, size: CGFloat, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(formatDistance(km))
                .font(.system(size: size, weight: .black, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.linear(duration: 0.3), value: km)
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(.secondaryLabel))
        }
    }

    private func formatDistance(_ km: Double) -> String {
        let meters = km * 1000
        if meters < 1000 {
            return String(format: "%.0f m", meters)
        } else {
            return String(format: "%.2f km", km)
        }
    }
}

// MARK: - Progress Bar
private struct ProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemFill))
                    .frame(height: 10)

                Capsule()
                    .fill(Color.appYellow)
                    .frame(width: max(geo.size.width * progress, 10), height: 10)

                Text("🏃")
                    .font(.system(size: 28))
                    .scaleEffect(x: -1, y: 1)
                    .offset(x: max(geo.size.width * progress - 16, 0), y: -22)

                Text("🏁")
                    .font(.system(size: 24))
                    .offset(x: geo.size.width - 20, y: -20)
            }
        }
        .frame(height: 40)
        .padding(.vertical, 12)
    }
}
