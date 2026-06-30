import SwiftUI
import MapKit

/// Поиск по заведениям с фильтрами (по спецификации).
struct SearchView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var location: LocationManager

    @State private var query = ""
    @State private var openNow = false
    @State private var minRating = 0        // 0 | 3 | 4
    @State private var maxDistance: Double? = nil   // км: 0.5 | 1 | 3 | 5
    @State private var category: VenueCategory?
    @State private var withDeals = false        // только с активными предложениями
    @State private var showMap = false
    @State private var mapSelection: Venue?

    private var anyFilterOn: Bool {
        openNow || withDeals || minRating > 0 || maxDistance != nil || category != nil
    }
    private func resetFilters() {
        openNow = false; withDeals = false; minRating = 0; maxDistance = nil; category = nil
    }

    private var results: [Venue] {
        // База уже отсортирована по релевантности (алгоритм ранжирования).
        store.rankedVenues().filter { venue in
            matchesQuery(venue) && matchesFilters(venue)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar
                if !showMap && (anyFilterOn || !query.isEmpty) {
                    HStack {
                        Text("Найдено: \(results.count)").font(.caption).foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 16).padding(.vertical, 6)
                }
                if showMap {
                    VenuesMapView(venues: results) { mapSelection = $0 }
                } else if results.isEmpty {
                    ScrollView {
                        ContentUnavailableView("Ничего не нашлось", systemImage: "magnifyingglass",
                            description: Text("Попробуй другое название или расширь расстояние."))
                            .padding(.top, 80)
                    }
                    .refreshable { await store.load() }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(results) { venue in
                                NavigationLink(value: venue) {
                                    VenueCard(venue: venue,
                                              distanceKm: location.distanceKm(to: venue.latitude, venue.longitude))
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical, 12)
                    }
                    .refreshable { await store.load() }
                }
            }
            .navigationTitle("Поиск")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showMap.toggle() } label: {
                        Image(systemName: showMap ? "list.bullet" : "map")
                    }
                }
            }
            .navigationDestination(item: $mapSelection) { VenueDetailView(venue: $0) }
            .searchable(text: $query, prompt: "Заведение, категория или акция")
            .onSubmit(of: .search) {
                AnalyticsLog.log(.search, ["query": query, "results": results.count])
            }
            .navigationDestination(for: Venue.self) { VenueDetailView(venue: $0) }
        }
    }

    // MARK: Фильтры

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if anyFilterOn {
                    Button { withAnimation { resetFilters() } } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.body).foregroundStyle(.secondary)
                            .padding(.horizontal, 4)
                    }
                    .buttonStyle(.plain)
                }
                chip("Открыто", systemImage: "clock", isOn: openNow) { openNow.toggle() }
                chip("Со скидкой", systemImage: "tag.fill", isOn: withDeals) { withDeals.toggle() }

                Menu {
                    Button("Любой рейтинг") { minRating = 0 }
                    Button("★ 3+") { minRating = 3 }
                    Button("★ 4+") { minRating = 4 }
                } label: {
                    chipLabel(minRating == 0 ? "Рейтинг" : "★ \(minRating)+",
                              systemImage: "star", isOn: minRating > 0)
                }

                Menu {
                    Button("Любое расстояние") { maxDistance = nil }
                    Button("500 м") { maxDistance = 0.5 }
                    Button("1 км") { maxDistance = 1 }
                    Button("3 км") { maxDistance = 3 }
                    Button("5 км") { maxDistance = 5 }
                } label: {
                    chipLabel(maxDistance == nil ? "Расстояние" : "≤ \(maxDistance!.distanceText)",
                              systemImage: "location", isOn: maxDistance != nil)
                }

                Menu {
                    Button("Все категории") { category = nil }
                    ForEach(VenueCategory.allCases) { cat in
                        Button { category = cat } label: { Label(cat.rawValue, systemImage: cat.icon) }
                    }
                } label: {
                    chipLabel(category?.rawValue ?? "Категория",
                              systemImage: "square.grid.2x2", isOn: category != nil)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color(.systemBackground))
        .overlay(Divider(), alignment: .bottom)
    }

    private func chip(_ title: String, systemImage: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) { chipLabel(title, systemImage: systemImage, isOn: isOn) }
            .buttonStyle(.plain)
    }

    private func chipLabel(_ title: String, systemImage: String, isOn: Bool) -> some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 12).padding(.vertical, 7)
            .background(isOn ? Color.sanAccent : Color(.systemGray6), in: Capsule())
            .foregroundStyle(isOn ? .white : .primary)
    }

    // MARK: Логика фильтрации

    private func matchesQuery(_ venue: Venue) -> Bool {
        guard !query.isEmpty else { return true }
        let q = query.trimmingCharacters(in: .whitespaces)
        // Заведение
        if venue.name.localizedCaseInsensitiveContains(q) { return true }
        if venue.category.rawValue.localizedCaseInsensitiveContains(q) { return true }
        if venue.district.localizedCaseInsensitiveContains(q) { return true }
        if venue.address.localizedCaseInsensitiveContains(q) { return true }
        // Объекты внутри заведения (блюда / услуги)
        if venue.items.contains(where: { $0.name.localizedCaseInsensitiveContains(q) }) { return true }
        // Предложения (название + описание)
        if store.deals(for: venue).contains(where: {
            $0.title.localizedCaseInsensitiveContains(q) || $0.details.localizedCaseInsensitiveContains(q)
        }) { return true }
        // Отзывы (текст + упомянутый объект)
        if store.reviews(for: venue).contains(where: {
            $0.text.localizedCaseInsensitiveContains(q) ||
            ($0.itemName?.localizedCaseInsensitiveContains(q) ?? false)
        }) { return true }
        return false
    }

    private func matchesFilters(_ venue: Venue) -> Bool {
        if openNow && !venue.isOpenNow { return false }
        if withDeals && store.deals(for: venue).isEmpty { return false }
        if let category, venue.category != category { return false }
        if minRating > 0 && store.aggregate(for: venue).rating < Double(minRating) { return false }
        if let maxDistance {
            guard let d = location.distanceKm(to: venue.latitude, venue.longitude),
                  d <= maxDistance else { return false }
        }
        return true
    }
}

// MARK: - Карта заведений

struct VenuesMapView: View {
    let venues: [Venue]
    var onSelect: (Venue) -> Void

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: City.bishkek.latitude,
                                           longitude: City.bishkek.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)))

    var body: some View {
        Map(position: $position) {
            ForEach(venues) { v in
                Annotation(v.name,
                           coordinate: CLLocationCoordinate2D(latitude: v.latitude,
                                                              longitude: v.longitude)) {
                    Button { onSelect(v) } label: {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundStyle(Color.sanAccent)
                            .background(Circle().fill(.white).padding(4))
                    }
                }
            }
        }
        .mapControls { MapUserLocationButton() }
    }
}

#Preview {
    SearchView()
        .environmentObject(AppStore())
        .environmentObject(LocationManager())
        .tint(.sanAccent)
}
