import SwiftUI
import FamilyControls

struct SetupView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var showingActivityPicker = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // MARK: 앱 선택
            Button {
                showingActivityPicker = true
            } label: {
                VStack(spacing: 10) {
                    Text("잠글 앱 추가")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)

                    HStack(spacing: 16) {
                        statLabel("카테고리", count: vm.selection.categories.count)
                        statLabel("앱", count: vm.selection.applications.count)
                        statLabel("사이트", count: vm.selection.webDomains.count)
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                }
            }
            .familyActivityPicker(
                isPresented: $showingActivityPicker,
                selection: $vm.selection
            )

            Spacer()

            // MARK: 잠글 시간 선택
            HStack(alignment: .center, spacing: 0) {
                Picker("시간", selection: $vm.lockHours) {
                    ForEach(0..<24, id: \.self) { h in
                        Text(String(format: "%02d", h))
                            .font(.system(size: 52, weight: .black, design: .rounded))
                            .tag(h)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 110)
                .clipped()

                Text("시간")
                    .font(.system(size: 22, weight: .bold))

                Picker("분", selection: $vm.lockMinutes) {
                    ForEach(0..<60, id: \.self) { m in
                        Text(String(format: "%02d", m))
                            .font(.system(size: 52, weight: .black, design: .rounded))
                            .tag(m)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 110)
                .clipped()

                Text("분")
                    .font(.system(size: 22, weight: .bold))
            }

            Text("잠글시간")
                .font(.system(size: 17, weight: .bold))
                .padding(.top, 6)

            Spacer()

            // MARK: 거리 설정
            VStack(spacing: 8) {
                Text(String(format: "%.2f", vm.targetDistance))
                    .font(.system(size: 80, weight: .black, design: .rounded))
                    .contentTransition(.numericText())
                    .animation(.snappy, value: vm.targetDistance)

                Text("끝나고 움직일 거리(km)")
                    .font(.system(size: 17, weight: .bold))

                HStack(spacing: 40) {
                    Button {
                        if vm.targetDistance > 0.5 {
                            withAnimation { vm.targetDistance -= 0.5 }
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.gray.opacity(0.35))
                    }

                    Button {
                        if vm.targetDistance < 20.0 {
                            withAnimation { vm.targetDistance += 0.5 }
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.gray.opacity(0.35))
                    }
                }
                .padding(.top, 4)
            }

            Spacer()

            // MARK: 시작 버튼
            Button("시작") {
                vm.startLock()
            }
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(.black)
            .frame(width: 150, height: 58)
            .background(Color.appYellow)
            .clipShape(Capsule())
            .disabled(vm.lockHours == 0 && vm.lockMinutes == 0)

            Spacer()
        }
        .background(Color.white.ignoresSafeArea())
    }

    private func statLabel(_ name: String, count: Int) -> some View {
        Text("\(name) : \(count)건")
    }
}
