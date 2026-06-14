import SwiftUI

/// Поиск по заведениям с фильтром по категориям.
struct SearchView: View {
    @EnvironmentObject private var store: AppStore
    @State private var query = ""
    @State private var category: VenueCategory?

    private var results: [Venue] {
        store.venues.filter { venue in
            let matchesCategory = category == nil || venue.category == category
            let matchesQuery = query.isEmpty
                || venue.name.localizedCaseInsensitiveContains(query)
                || venue.district.localizedCaseInsensitiveContains(query)
            return matchesCategory && matchesQuery
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(results) { venue in
                        NavigationLink(value: venue) {
                            venueRow(venue)
                        }
                    }
                } header: {
                    categoryChips
                        .textCase(nil)
                        .listRowInsets(EdgeInsets())
                }
            }
            .listStyle(.plain)
            .navigationTitle("Поиск")
            .searchable(text: $query, prompt: "Заведение или район")
            .navigationDestination(for: Venue.self) { venue in
                VenueDetailView(venue: venue)
            }
            .overlay {
                if results.isEmpty {
                    ContentUnavailableView("Ничего не нашлось",
                                           systemImage: "magnifyingglass",
                                           description: Text("Попробуй другой запрос или категорию"))
                }
            }
        }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(VenueCategory.allCases) { cat in
                    let isOn = category == cat
                    Button {
                        category = isOn ? nil : cat
                    } label: {
                        Label(cat.rawValue, systemImage: cat.icon)
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(isOn ? Color.sanAccent : Color(.systemGray6),
                                        in: Capsule())
                            .foregroundStyle(isOn ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    private func venueRow(_ venue: Venue) -> some View {
        HStack(spacing: 12) {
            VenueAvatar(venue: venue, size: 48)
            VStack(alignment: .leading, spacing: 3) {
                Text(venue.name)
                    .font(.subheadline.weight(.semibold))
                Text("\(venue.category.rawValue) • \(venue.district)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            let count = store.deals(for: venue).count
            if count > 0 {
                Text("\(count) САН")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.sanAccent.opacity(0.12), in: Capsule())
                    .foregroundStyle(Color.sanAccent)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    SearchView()
        .environmentObject(AppStore())
        .tint(.sanAccent)
}
