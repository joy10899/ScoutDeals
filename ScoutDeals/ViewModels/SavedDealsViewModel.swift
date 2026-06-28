//
//  SavedDealsViewModel.swift
//  ScoutDeals
//
//  Created by Joy on 6/27/26.
//  Pure state engine — no SwiftUI types. Safe to unit-test in isolation.
//  Drives the Saved Deals screen via the @Observable macro (iOS 17+).

import Foundation
import Observation

// MARK: - View State
// Explicit state machine. Makes impossible states (loading + content
// visible)unrepresentable at the type level.

enum ViewState: Equatable{
    case loading
    case empty
    case loaded([Deal])
    
    static func == (lhs: ViewState, rhs: ViewState) -> Bool {
        switch (lhs, rhs)  {
        case (.loading, .loading), (.empty, .empty): return true
        case (.loaded(let a), .loaded(let b)): return a.map(\.id) == b.map(\.id)
        default: return false
        }
    }
}

// MARK: - Filter

enum CategoryFilter: Hashable {
    case all
    case category(DealCategory)

    var label: String {
        switch self {
        case .all: return "All"
        case .category(let c): return c.rawValue
        }
    }
}

// MARK: - ViewModel
@Observable
final class SavedDealsViewModel {
    
    // MARK: Public State
    
    private(set) var state: ViewState = .loading
    var selectedDeal: Deal?
    var activeFilter: CategoryFilter = .all

    // MARK: Init

    init() {}

    // Seed a specific state directly. Intended for SwiftUI previews and tests
    // that need to render a fixed state without running `loadDeals()`.
    init(state: ViewState) {
        self.state = state
    }

    // MARK: Derived
    // Filtered subset used by the list — computed on demand from raw state.
    var filteredDeals: [Deal] {
        guard case .loaded(let deals) = state else { return [] }
        switch activeFilter {
        case .all: return deals
        case .category(let cat): return deals.filter {$0.category == cat}
        }
    }
    
    var hasActiveDeals: Bool {
        if case .loaded = state {return true}
        return false
    }
    
    // MARK: Intents
    // Kick off the initial data load. Call from `.task {}` on the owning view.
    func loadDeals() async {
        state = .loading
        try? await Task.sleep(for: .seconds(1.2))
        let deals = Deal.mockDeals
        state = deals.isEmpty ? .empty : .loaded(deals)
    }
    
    func selectDeal(_ deal: Deal) {
        selectedDeal = deal
    }

    func clearSelection() {
        selectedDeal = nil
    }
    
    // Persist a price-drop alert for a saved item.
    // Stub — wire to Core Data + UNUserNotificationCenter in production.
    func setAlert(for deal: Deal, threshold: Double) {
        // TODO: schedule local notification or register server-side webhook
        print("Alert set: \(deal.brand) \(deal.name) @ \(threshold.formatted(.currency(code: "USD")))")
        clearSelection()
    }
    
}
