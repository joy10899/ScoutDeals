//
//  Deal.swift
//  ScoutDeals
//
//  Created by Joy on 6/27/26.
//  Core data model for a saved clothing item. Conforms to Codable for
//  future API decoding. No SwiftUI dependency — pure Swift value type.
//

import Foundation

struct Deal : Identifiable, Hashable, Codable {
    let id: UUID
    let brand: String
    let name: String
    let category: DealCategory
    let currentPrice: Double
    let originalPrice: Double
    let retailer: String
    let imageURL: String
    
    // Calculated discount rounded to the nearest whole percent.
    var discountPercentage : Int {
        guard originalPrice > 0 else {return 0}
        return Int(((originalPrice - currentPrice) / originalPrice ) * 100)
    }
    
    // Formatted savings amount for display.
    var savingsAmount: Double {
        originalPrice - currentPrice
    }
    
    init(
        id: UUID = UUID(),
        brand: String,
        name: String,
        category: DealCategory,
        currentPrice: Double,
        originalPrice: Double,
        retailer: String,
        imageURL: String
    ) {
        self.id = id
        self.brand = brand
        self.name = name
        self.category = category
        self.currentPrice = currentPrice
        self.originalPrice = originalPrice
        self.retailer = retailer
        self.imageURL = imageURL
    }
}

// MARK: - Category

enum DealCategory : String, Codable, CaseIterable {
    case dresses    = "Dresses"
    case tops       = "Tops"
    case denim      = "Denim"
    case outerwear  = "Outerwear"
    case shoes      = "Shoes"
    case accessories = "Accessories"
    
    var systemImage: String {
            switch self {
            case .dresses:     return "sparkles"
            case .tops:        return "tshirt"
            case .denim:       return "rectangle.3.group"
            case .outerwear:   return "cloud.rain"
            case .shoes:       return "shoeprints.walk"
            case .accessories: return "bag"
            }
        }
}

// MARK: - Mock Data
// Reflects real brands and price points SCOUT users track (Reformation,
// Free People, Anthropologie, Madewell, AGOLDE, Veronica Beard).

extension Deal {
    static let mockDeals : [Deal] = [
        Deal(
            brand: "Reformation",
            name: "Petite Celia Dress",
            category: .dresses,
            currentPrice: 148.00,
            originalPrice: 248.00,
            retailer: "Reformation",
            imageURL: "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=400"
        ),
        Deal(
            brand: "Free People",
            name: "Movement Never Better Legging",
            category: .tops,
            currentPrice: 48.00,
            originalPrice: 78.00,
            retailer: "Free People",
            imageURL: "https://images.unsplash.com/photo-1506629082955-511b1aa562c8?w=400"
        ),
        Deal(
            brand: "AGOLDE",
            name: "90s Pinch Waist High Rise Straight Jeans",
            category: .denim,
            currentPrice: 178.00,
            originalPrice: 248.00,
            retailer: "Nordstrom",
            imageURL: "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=400"
        ),
        Deal(
            brand: "Veronica Beard",
            name: "Lyndale Dickey Jacket",
            category: .outerwear,
            currentPrice: 395.00,
            originalPrice: 595.00,
            retailer: "Veronica Beard",
            imageURL: "https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=400"
        ),
        Deal(
            brand: "Anthropologie",
            name: "Maeve Floral Midi Skirt",
            category: .dresses,
            currentPrice: 89.95,
            originalPrice: 148.00,
            retailer: "Anthropologie",
            imageURL: "https://images.unsplash.com/photo-1588117305388-c2631a279f82?w=400"
        ),
    ]
}

