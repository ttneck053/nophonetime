import SwiftUI

struct RunReadyView: View {
    @EnvironmentObject var vm: AppViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // MARK: 거리 표시
            VStack(spacing: 12) {
                Text("움직일 거리")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)

                Text(String(format: "%.1fkm", vm.targetDistance))
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(.appPink)
            }

            Spacer().frame(height: 48)

            // MARK: 시작 버튼
            Button("시작") {
                vm.startRunning()
            }
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(.black)
            .frame(width: 150, height: 58)
            .background(Color.appYellow)
            .clipShape(Capsule())

            Spacer().frame(height: 48)

            // MARK: 안내 문구
            Text("이게 끝나야 잠금이 해제 됩니다.")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)

            Spacer()
        }
        .background(Color.white.ignoresSafeArea())
    }
}
