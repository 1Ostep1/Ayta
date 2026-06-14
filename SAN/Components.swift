import SwiftUI

// MARK: - Аватар заведения

struct VenueAvatar: View {
    let venue: Venue
    var size: CGFloat = 40

    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: venue.gradient,
                                     startPoint: .topLeading,
                                     endPoint: .bottomTrailing))
            Text(venue.emoji)
                .font(.system(size: size * 0.5))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Бейдж типа предложения

struct DealTypeBadge: View {
    let type: DealType

    var body: some View {
        Label(type.rawValue, systemImage: type.icon)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(type.color, in: Capsule())
    }
}

// MARK: - Цены

struct PriceLabel: View {
    let deal: Deal

    var body: some View {
        HStack(spacing: 8) {
            if let old = deal.oldPrice {
                Text(old.som)
                    .strikethrough()
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
            if let new = deal.newPrice {
                Text(new.som)
                    .font(.headline)
                    .foregroundStyle(Color.sanAccent)
            }
        }
    }
}

// MARK: - Карточка ленты (инста-формат)

struct DealCard: View {
    let deal: Deal
    var onTap: () -> Void = {}
    @EnvironmentObject private var store: AppStore

    private var venue: Venue? { store.venue(for: deal) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            visual
            actions
            caption
        }
        .background(Color(.systemBackground))
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }

    private var header: some View {
        HStack(spacing: 10) {
            if let venue { VenueAvatar(venue: venue) }
            VStack(alignment: .leading, spacing: 1) {
                Text(venue?.name ?? "")
                    .font(.subheadline.weight(.semibold))
                Text("\(venue?.category.rawValue ?? "") • \(venue?.district ?? "")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            DealTypeBadge(type: deal.type)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }

    private var visual: some View {
        ZStack {
            LinearGradient(colors: venue?.gradient ?? [.sanAccent, .orange],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            Text(deal.emoji)
                .font(.system(size: 90))
                .shadow(radius: 8)

            if let percent = deal.discountPercent {
                Text("−\(percent)%")
                    .font(.title2.weight(.heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.black.opacity(0.35), in: Capsule())
                    .frame(maxWidth: .infinity, maxHeight: .infinity,
                           alignment: .topLeading)
                    .padding(12)
            }
        }
        .frame(height: 280)
        .clipped()
    }

    private var actions: some View {
        HStack(spacing: 18) {
            Button {
                store.toggleFavorite(deal)
            } label: {
                Image(systemName: store.isFavorite(deal) ? "heart.fill" : "heart")
                    .font(.title2)
                    .foregroundStyle(store.isFavorite(deal) ? Color.sanAccent : .primary)
            }
            .buttonStyle(.plain)

            ShareLink(item: "\(deal.title) — \(venue?.name ?? ""), \(venue?.address ?? ""). Нашёл в САН!") {
                Image(systemName: "paperplane")
                    .font(.title2)
                    .foregroundStyle(.primary)
            }

            Spacer()

            Label("до \(deal.validUntil.sanShort)", systemImage: "clock")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var caption: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(deal.title)
                .font(.headline)
            Text(deal.details)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            PriceLabel(deal: deal)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Компактная строка предложения (поиск, избранное, заведение)

struct CompactDealRow: View {
    let deal: Deal
    var showVenue = true
    @EnvironmentObject private var store: AppStore

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(colors: store.venue(for: deal)?.gradient ?? [.sanAccent, .orange],
                                         startPoint: .topLeading,
                                         endPoint: .bottomTrailing))
                Text(deal.emoji).font(.title2)
            }
            .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 3) {
                Text(deal.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                if showVenue {
                    Text("\(store.venue(for: deal)?.name ?? "") • до \(deal.validUntil.sanShort)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("до \(deal.validUntil.sanShort)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                store.toggleFavorite(deal)
            } label: {
                Image(systemName: store.isFavorite(deal) ? "heart.fill" : "heart")
                    .foregroundStyle(store.isFavorite(deal) ? Color.sanAccent : .secondary)
            }
            .buttonStyle(.plain)
        }
        .contentShape(Rectangle())
    }
}
