//
//  SavedDealsView.swift
//  ScoutDeals
//
//  Created by Joy on 6/27/26.
//

import SwiftUI

struct SavedDealsView: View {

    // MARK: State
    @State private var viewModel: SavedDealsViewModel

    // Inject a view model (previews/tests) or fall back to a fresh one.
    // `@State` must be seeded via its `State(initialValue:)` backing store.
    init(viewModel: SavedDealsViewModel = SavedDealsViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    // MARK: Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.hasActiveDeals {
                    categoryFilterBar
                }
                stateContent
            }
            .navigationTitle("Saved Deals")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    savingsIndicator
                }
            }
        }
        .sheet(item: $viewModel.selectedDeal) { deal in
            NotificationSheet(deal: deal) { threshold in
                viewModel.setAlert(for: deal, threshold: threshold)
            }
        }
        .task {
            await viewModel.loadDeals()
        }
    }
    
    // MARK: Category Filter Bar
    private var categoryFilterBar: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        label: "All",
                        isSelected: viewModel.activeFilter == .all
                    ) {
                        viewModel.activeFilter = .all
                    }

                    ForEach(DealCategory.allCases, id: \.self) { category in
                        FilterChip(
                            label: category.rawValue,
                            isSelected: viewModel.activeFilter == .category(category)
                        ) {
                            viewModel.activeFilter = .category(category)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .background(Color(.systemGroupedBackground))
        }
    
    // MARK: Total Savings Indicator
       @ViewBuilder
       private var savingsIndicator: some View {
           if case .loaded(let deals) = viewModel.state {
               let total = deals.reduce(0) { $0 + $1.savingsAmount }
               if total > 0 {
                   Label(total.formatted(.currency(code: "USD")), systemImage: "tag.fill")
                       .font(.caption)
                       .fontWeight(.semibold)
                       .foregroundStyle(.green)
                       .accessibilityLabel("Total potential savings: \(total.formatted(.currency(code: "USD")))")
               }
           }
       }
    
    // MARK: State Switch
    @ViewBuilder
    private var stateContent: some View {
        switch viewModel.state {
        case .loading:
            loadingView
        case .empty:
            emptyView
        case .loaded:
            dealsList
        }
    }
    
    // MARK: Sub-Views
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
            Text("Fetching your saved deals…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "No Saved Deals",
            systemImage: "tag.slash",
            description: Text("Save clothing items from Reformation, Free People, Anthropologie and more — Scout will alert you the moment their price drops.")
        )
    }
    
    private var dealsList: some View {
        List(viewModel.filteredDeals) { deal in
            Button {
                viewModel.selectDeal(deal)
            } label: {
                DealRow(deal: deal)
            }
            .buttonStyle(.plain)
        }
        .listStyle(.insetGrouped)
        .overlay {
            // Empty filtered state — different from global empty state
            if viewModel.filteredDeals.isEmpty {
                ContentUnavailableView(
                    "No \(viewModel.activeFilter.label) Deals",
                    systemImage: "line.3.horizontal.decrease.circle",
                    description: Text("Try a different category filter.")
                )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.activeFilter)
    }
}
    
// MARK: - Filter Chip
private struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    isSelected ? Color.accentColor : Color(.systemGray5),
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Previews

#Preview("Loaded — All Deals") {
    let vm = SavedDealsViewModel(state: .loaded(Deal.mockDeals))
    SavedDealsView(viewModel: vm)
}

#Preview("Loaded — Dresses Filter") {
    let vm = SavedDealsViewModel(state: .loaded(Deal.mockDeals))
    return SavedDealsView(viewModel: vm)
        .onAppear { vm.activeFilter = .category(.dresses) }
}

#Preview("Loading State") {
    VStack(spacing: 16) {
        ProgressView().controlSize(.large)
        Text("Fetching your saved deals…")
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}

#Preview("Empty State") {
    ContentUnavailableView(
        "No Saved Deals",
        systemImage: "tag.slash",
        description: Text("Save clothing items from Reformation, Free People, Anthropologie and more — Scout will alert you the moment their price drops.")
    )
}
