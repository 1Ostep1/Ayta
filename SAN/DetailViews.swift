import SwiftUI

// MARK: - Детали предложения

struct DealDetailView: View {
    let deal: Deal
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    private var venue: Venue? { store.venue(for: deal) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    hero

                    VStack(alignment: .leading, spacing: 10) {
                        DealTypeBadge(type: deal.type)
                        Text(deal.title)
                            .font(.title2.weight(.bold))
                        Text(deal.details)
                            .font(.body)
                            .foregroundStyle(.secondary)
                        PriceLabel(deal: deal)
                        Label("Действует до \(deal.validUntil.sanShort)", systemImage: "clock")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)

                    showAtVenue
                    if venue != nil { venueSection }
                }
                .padding(.bottom, 24)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") { dismiss() }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        store.toggleFavorite(deal)
                    } label: {
                        Image(systemName: store.isFavorite(deal) ? "heart.fill" : "heart")
                    }
                }
            }
        }
    }

    private var hero: some View {
        ZStack {
            if let gradient = venue?.gradient {
                LinearGradient(colors: gradient,
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
            } else {
                LinearGradient(colors: [.sanAccent, .orange],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
            }
            Text(deal.emoji)
                .font(.system(size: 100))
                .shadow(radius: 10)
            if let percent = deal.discountPercent {
                Text("−\(percent)%")
                    .font(.title.weight(.heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.black.opacity(0.35), in: Capsule())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(16)
            }
        }
        .frame(height: 260)
        .clipped()
    }

    private var showAtVenue: some View {
        HStack(spacing: 12) {
            Image(systemName: "qrcode.viewfinder")
                .font(.title)
                .foregroundStyle(Color.sanAccent)
            VStack(alignment: .leading, spacing: 2) {
                Text("Покажи этот экран сотруднику")
                    .font(.subheadline.weight(.semibold))
                Text("Код: САН-\(deal.id.uppercased())")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.sanAccent.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var venueSection: some View {
        if let venue {
            VStack(alignment: .leading, spacing: 12) {
                Text("Заведение")
                    .font(.headline)
                HStack(spacing: 12) {
                    VenueAvatar(venue: venue, size: 48)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(venue.name)
                            .font(.subheadline.weight(.semibold))
                        Text("\(venue.category.rawValue) • \(venue.district)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Label(venue.address, systemImage: "mappin.and.ellipse")
                    .font(.subheadline)
                if let url = URL(string: "tel:\(venue.phone.filter { !$0.isWhitespace })") {
                    Link(destination: url) {
                        Label(venue.phone, systemImage: "phone.fill")
                            .font(.subheadline)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Страница заведения

struct VenueDetailView: View {
    let venue: Venue
    @EnvironmentObject private var store: AppStore
    @State private var selectedDeal: Deal?

    private var deals: [Deal] { store.deals(for: venue) }

    var body: some View {
        List {
            Section {
                VStack(spacing: 12) {
                    VenueAvatar(venue: venue, size: 84)
                    Text(venue.name)
                        .font(.title2.weight(.bold))
                    Text("\(venue.category.rawValue) • \(venue.district)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .listRowSeparator(.hidden)
            }

            Section("Контакты") {
                Label(venue.address, systemImage: "mappin.and.ellipse")
                if let url = URL(string: "tel:\(venue.phone.filter { !$0.isWhitespace })") {
                    Link(destination: url) {
                        Label(venue.phone, systemImage: "phone.fill")
                    }
                }
            }

            Section("Активные предложения") {
                if deals.isEmpty {
                    Text("Пока нет активных предложений")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(deals) { deal in
                        CompactDealRow(deal: deal, showVenue: false)
                            .onTapGesture { selectedDeal = deal }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(venue.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedDeal) { deal in
            DealDetailView(deal: deal)
        }
    }
}

#Preview {
    let store = AppStore()
    DealDetailView(deal: MockData.deals[0])
        .environmentObject(store)
        .tint(.sanAccent)
}
