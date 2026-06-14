import SwiftUI

/// Главная: инста-лента из скидок, акций и новинок (САН).
struct HomeFeedView: View {
    @EnvironmentObject private var store: AppStore
    @State private var filter: DealType?
    @State private var selectedDeal: Deal?

    private var feed: [Deal] {
        let all = store.activeDeals
        guard let filter else { return all }
        return all.filter { $0.type == filter }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 28) {
                    filterRow
                    if store.isLoading {
                        ProgressView()
                            .padding(.top, 40)
                    } else {
                        ForEach(feed) { deal in
                            DealCard(deal: deal) { selectedDeal = deal }
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .navigationTitle("САН • Бишкек")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedDeal) { deal in
                DealDetailView(deal: deal)
            }
        }
    }

    // Сторис-стайл фильтры по типу
    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 18) {
                storyCircle(label: "Все", icon: "flame.fill",
                            color: .orange, isOn: filter == nil) {
                    filter = nil
                }
                ForEach(DealType.allCases) { type in
                    storyCircle(label: type.rawValue, icon: type.icon,
                                color: type.color, isOn: filter == type) {
                        filter = (filter == type) ? nil : type
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func storyCircle(label: String, icon: String, color: Color,
                             isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .strokeBorder(
                            isOn
                            ? AnyShapeStyle(LinearGradient(colors: [color, .yellow],
                                                           startPoint: .topLeading,
                                                           endPoint: .bottomTrailing))
                            : AnyShapeStyle(Color(.systemGray4)),
                            lineWidth: 2.5
                        )
                        .frame(width: 64, height: 64)
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(color)
                }
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(isOn ? .primary : .secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeFeedView()
        .environmentObject(AppStore())
        .tint(.sanAccent)
}





