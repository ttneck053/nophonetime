import SwiftUI

struct LockedView: View {
    @EnvironmentObject var vm: AppViewModel

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 8) {
                    Text("조금만 참아봅시다... 솔직히 이정돈 할 수 있잖아?")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(.secondaryLabel))
                        .textCase(.uppercase)
                        .tracking(1.5)

                    Text(vm.formattedRemaining)
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundColor(Color(.label))
                        .monospacedDigit()
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                        .contentTransition(.numericText(countsDown: true))
                        .animation(.linear(duration: 0.3), value: vm.remainingSeconds)
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 48)

                VStack(spacing: 4) {
                    Text(formatDistance(vm.targetDistance))
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.appPink)

                    Text("잠금 끝나고 움직일 거리")
                        .font(.system(size: 13))
                        .foregroundColor(Color(.secondaryLabel))
                }

                Spacer()
            }
        }
    }

    private func formatDistance(_ km: Double) -> String {
        let meters = Int((km * 1000).rounded())
        if meters < 1000 {
            return "\(meters) m"
        } else {
            return String(format: "%.1f km", km)
        }
    }
}
