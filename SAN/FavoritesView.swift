import SwiftUI

/// Избранное: сохранённые предложения, persistence через UserDefaults.
struct FavoritesView: View {
    @EnvironmentObject private var store: AppStore
    @State private var selectedDeal: Deal?

    var body: some View {
        NavigationStack {
            Group {
                if store.favoriteDeals.isEmpty {
                    ContentUnavailableView(
                        "Пока пусто",
                        systemImage: "heart",
                        description: Text("Нажимай ♥ на предложениях в ленте,\nчтобы не потерять их")
                    )
                } else {
                    List {
                        ForEach(store.favoriteDeals) { deal in
                            CompactDealRow(deal: deal)
                                .onTapGesture { selectedDeal = deal }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Избранное")
            .sheet(item: $selectedDeal) { deal in
                DealDetailView(deal: deal)
            }
        }
    }
}

#Preview {
    FavoritesView()
        .environmentObject(AppStore())
        .tint(.sanAccent)
}
