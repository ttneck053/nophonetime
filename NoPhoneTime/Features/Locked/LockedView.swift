import SwiftUI

struct LockedView: View {
    @EnvironmentObject var vm: AppViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // MARK: 카운트다운
            VStack(spacing: 12) {
                Text("잠근시간")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)

                Text(vm.formattedRemaining)
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundColor(.appPink)
                    .monospacedDigit()
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.linear(duration: 0.3), value: vm.remainingSeconds)
            }

            Spacer().frame(height: 56)

            // MARK: 목표 거리
            VStack(spacing: 8) {
                Text("끝나고 움직일 거리")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)

                Text(String(format: "%.1fkm", vm.targetDistance))
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.appPink)
            }

            Spacer()
        }
        .background(Color.white.ignoresSafeArea())
    }
}
