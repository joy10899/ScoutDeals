//
//  DealRowView.swift
//  ScoutDeals
//
//  Created by Joy on 6/27/26.
//

import SwiftUI

struct DealRow: View {
    let deal : Deal
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            AsyncImage(url: URL(string: deal.imageURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure, .empty:
                    Image(systemName: deal.category.systemImage)
                        .font(.title2)
                        .foregroundColor(.secondary)
                @unknown default:
                    ProgressView()
                }
            }
            .frame(width: 64, height:  64)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
            
            // Text block
            VStack(alignment: .leading, spacing: 3) {
                Text(deal.brand.uppercased())
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .tracking(0.6)
                
                Text(deal.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                
                HStack(spacing: 6) {
                    Text(deal.originalPrice, format: .currency(code: "USD"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .strikethrough(true, color: .secondary)

                    Text(deal.currentPrice, format: .currency(code: "USD"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("ScoutGreen", bundle: nil) ?? .green)

                    Text("at \(deal.retailer)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
            
            DiscountBadge(percentage: deal.discountPercentage)
        }
        .padding(.vertical, 6)
        // Synthesised accessibility label so VoiceOver reads the row as one
        // coherent sentence instead of each Text view in isolation.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
    }
    
    private var accessibilityDescription: String {
        "\(deal.brand) \(deal.name), now \(deal.currentPrice.formatted(.currency(code: "USD"))), " +
        "down from \(deal.originalPrice.formatted(.currency(code: "USD"))), " +
        "\(deal.discountPercentage) percent off at \(deal.retailer)"
    }
}

// MARK: - Discount Badge

private struct DiscountBadge: View {
    let percentage: Int

    var body: some View {
        Text("-\(percentage)%")
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(badgeColor, in: Capsule())
    }

    // Deeper discount = more urgent red; modest discount stays coral.
    private var badgeColor: Color {
        percentage >= 40 ? .red : Color(red: 0.93, green: 0.35, blue: 0.35)
    }
}

#Preview("Deal Row") {
    List {
        DealRow(deal: Deal.mockDeals[0])   // Reformation dress
        DealRow(deal: Deal.mockDeals[2])   // AGOLDE jeans
        DealRow(deal: Deal.mockDeals[3])   // Veronica Beard jacket
    }
    .listStyle(.insetGrouped)
}
