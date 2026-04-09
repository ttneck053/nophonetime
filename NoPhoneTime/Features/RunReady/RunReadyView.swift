import SwiftUI

struct RunReadyView: View {
    @EnvironmentObject var vm: AppViewModel

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 6) {
                    Text("잠금 해제됨")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(.secondaryLabel))
                        .textCase(.uppercase)
                        .tracking(1.5)

                    Text(formatDistance(vm.targetDistance))
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundColor(.appPink)

                    Text("위 거리를 움직여야 잠금이 해제 됩니다.")
                        .font(.system(size: 14))
                        .foregroundColor(Color(.secondaryLabel))
                        .padding(.top, 4)
                }

                Spacer()

                Button {
                    vm.startRunning()
                } label: {
                    Text("움직이기 시작")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.appYellow)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
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
