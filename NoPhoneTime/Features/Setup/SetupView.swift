import SwiftUI
import FamilyControls

struct SetupView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var showingActivityPicker = false
    @State private var showEmptySelectionAlert = false

    private let pickerH: CGFloat = 64
    private let pickerW: CGFloat = 72
    private let fontSize: CGFloat = 22

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {

                Spacer()

                // MARK: 앱 선택
                Button { showingActivityPicker = true } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("잠글 앱")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(.label))
                            Text("앱 \(vm.selection.applicationTokens.count) · 카테고리 \(vm.selection.categoryTokens.count) · 사이트 \(vm.selection.webDomainTokens.count)")
                                .font(.system(size: 12))
                                .foregroundColor(Color(.secondaryLabel))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                }
                .sheet(isPresented: $showingActivityPicker) {
                    NavigationView {
                        FamilyActivityPicker(selection: $vm.selection)
                            .navigationTitle("잠금 앱 추가")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button("저장") { showingActivityPicker = false }
                                }
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button { showingActivityPicker = false } label: {
                                        Image(systemName: "xmark")
                                    }
                                }
                            }
                    }
                }

                Spacer().frame(height: 30)

                // MARK: 잠금 시간
                VStack(spacing: 6) {
                    Text("인터넷에서 떠날 시간")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(.secondaryLabel))

                    HStack(spacing: 8) {
                        wheelPicker(selection: $vm.lockHours, items: Array(0..<24), format: "%02d")
                        Text("시간").font(.system(size: 13, weight: .medium)).foregroundColor(Color(.secondaryLabel))
                        wheelPicker(selection: $vm.lockMinutes, items: Array(0..<60), format: "%02d")
                        Text("분").font(.system(size: 13, weight: .medium)).foregroundColor(Color(.secondaryLabel))
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                Spacer().frame(height: 30)

                // MARK: 해제 조건 거리
                VStack(spacing: 6) {
                    Text("해제 조건 거리")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(.secondaryLabel))

                    HStack(spacing: 8) {
                        wheelPicker(
                            selection: Binding(get: { vm.targetKm }, set: { vm.targetKm = $0 }),
                            items: Array(0...20),
                            format: "%d"
                        )
                        Text("km").font(.system(size: 13, weight: .medium)).foregroundColor(Color(.secondaryLabel))
                        wheelPicker(
                            selection: Binding(get: { vm.targetMeters }, set: { vm.targetMeters = $0 }),
                            items: Array(stride(from: 0, through: 990, by: 10)),
                            format: "%03d"
                        )
                        Text("m").font(.system(size: 13, weight: .medium)).foregroundColor(Color(.secondaryLabel))
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                Spacer().frame(height: 30)

                // MARK: 시작 버튼
                Button {
                    let isEmpty = vm.selection.applicationTokens.isEmpty
                        && vm.selection.categoryTokens.isEmpty
                        && vm.selection.webDomainTokens.isEmpty
                    if isEmpty { showEmptySelectionAlert = true }
                    else { vm.startLock() }
                } label: {
                    Text("시작")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 160, height: 46)
                        .background(vm.lockHours == 0 && vm.lockMinutes == 0 ? Color(.systemFill) : Color.appYellow)
                        .clipShape(Capsule())
                }
                .disabled(vm.lockHours == 0 && vm.lockMinutes == 0)

                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .alert("잠글 앱을 선택해주세요", isPresented: $showEmptySelectionAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("앱, 카테고리, 사이트 중 하나 이상 선택해야 합니다.")
        }
    }

    @ViewBuilder
    private func wheelPicker(selection: Binding<Int>, items: [Int], format: String) -> some View {
        Picker("", selection: selection) {
            ForEach(items, id: \.self) { i in
                Text(String(format: format, i))
                    .font(.system(size: fontSize, weight: .bold, design: .rounded))
                    .tag(i)
            }
        }
        .pickerStyle(.wheel)
        .frame(width: pickerW, height: pickerH)
        .clipped()
    }
}
