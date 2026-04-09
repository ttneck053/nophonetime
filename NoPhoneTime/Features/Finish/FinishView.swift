import SwiftUI

struct FinishView: View {
    @EnvironmentObject var vm: AppViewModel

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 8) {
                    Text("완료!")
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundColor(Color(.label))

                    Text("잠금이 해제되었습니다")
                        .font(.system(size: 15))
                        .foregroundColor(Color(.secondaryLabel))
                }
                .onAppear {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }

                Spacer()

                Button {
                    vm.reset()
                } label: {
                    Text("처음으로")
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
}
