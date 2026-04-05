import SwiftUI

struct FinishView: View {
    @EnvironmentObject var vm: AppViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("끝!")
                .font(.system(size: 88, weight: .black, design: .rounded))
                .foregroundColor(.appPink)
                .scaleEffect(1.0)
                .onAppear {
                    // 완료 햅틱
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }

            Spacer().frame(height: 56)

            Button("처음으로") {
                vm.reset()
            }
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(.black)
            .frame(width: 160, height: 58)
            .background(Color.appYellow)
            .clipShape(Capsule())

            Spacer()
        }
        .background(Color.white.ignoresSafeArea())
    }
}
