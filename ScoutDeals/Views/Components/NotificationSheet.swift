//
//  NotificationSheet.swift
//  ScoutDeals
//
//  Created by Joy on 6/27/26.
//  Self-contained price-alert sheet for a clothing item. Receives a Deal
//  and an action closure — no ViewModel dependency — so it can be
//  composed from any screen in the app.

import SwiftUI

struct NotificationSheet: View {
    // MARK: Input
    let deal: Deal
    
    // Invoked with the validated threshold when "Set Alert" is tapped.
    var onSetAlert: (Double) -> Void

    // MARK: Private State
    @State private var thresholdText: String = ""
    @Environment(\.dismiss) private var dismiss
    
    // MARK: Validation
    
    private var parsedThreshold: Double? { Double(thresholdText) }
    
    private var validationMessage: String? {
        guard !thresholdText.isEmpty else { return nil }
        guard let value = parsedThreshold, value > 0 else {
            return "Please enter a valid price."
        }
        if value >= deal.currentPrice {
            return "Target must be below the current price of \(deal.currentPrice.formatted(.currency(code: "USD")))."
        }
        return nil
    }
    
    private var isValid: Bool {
        guard let value = parsedThreshold else { return false }
        return value > 0 && value < deal.currentPrice
    }
    
    // MARK: Body

    var body: some View {
        NavigationStack {
            Form {
                productHeaderSection
                priceBreakdownSection
                alertThresholdSection
                setAlertSection
            }
            .navigationTitle("Price Alert")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    // MARK: Sections

        /// Visual product header — mirrors the thumbnail style in DealRow.
        private var productHeaderSection: some View {
            Section {
                HStack(spacing: 14) {
                    AsyncImage(url: URL(string: deal.imageURL)) { phase in
                        if case .success(let image) = phase {
                            image.resizable().scaledToFill()
                        } else {
                            Image(systemName: deal.category.systemImage)
                                .font(.title)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(deal.brand.uppercased())
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .tracking(0.6)

                        Text(deal.name)
                            .font(.body)
                            .fontWeight(.medium)
                            .lineLimit(3)

                        Text(deal.retailer)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    
    private var priceBreakdownSection: some View {
            Section("Price Breakdown") {
                LabeledContent("Original Price") {
                    Text(deal.originalPrice, format: .currency(code: "USD"))
                        .foregroundStyle(.secondary)
                        .strikethrough()
                }
                LabeledContent("Sale Price") {
                    Text(deal.currentPrice, format: .currency(code: "USD"))
                        .foregroundStyle(.green)
                        .fontWeight(.semibold)
                }
                LabeledContent("You Save") {
                    HStack(spacing: 4) {
                        Text(deal.savingsAmount, format: .currency(code: "USD"))
                        Text("(\(deal.discountPercentage)% off)")
                            .foregroundStyle(.red)
                    }
                    .fontWeight(.medium)
                }
            }
        }
    
    private var alertThresholdSection: some View {
            Section {
                HStack {
                    Text("$").foregroundStyle(.secondary)
                    TextField("e.g. \((deal.currentPrice * 0.85).formatted(.number.precision(.fractionLength(2))))",
                              text: $thresholdText)
                        .keyboardType(.decimalPad)
                }

                if let message = validationMessage {
                    Label(message, systemImage: "exclamationmark.circle")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            } header: {
                Text("Alert me when price drops to")
            } footer: {
                Text("Scout will send you a push notification the moment this item dips below your target price.")
            }
        }
    
    private var setAlertSection: some View {
            Section {
                Button {
                    if let threshold = parsedThreshold {
                        onSetAlert(threshold)
                    }
                } label: {
                    Label("Set Price Alert", systemImage: "bell.badge")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .fontWeight(.semibold)
                }
                .disabled(!isValid)
            }
        }
}

#Preview {
    NotificationSheet(deal: Deal.mockDeals[0]) {
        threshold in print("Alert set at \(threshold)")
    }
}
