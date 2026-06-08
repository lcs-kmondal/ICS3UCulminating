//
//  Ship.swift
//  ICS3UCulminating
//

import Foundation

enum ShipType: String, CaseIterable, Codable {
    case carrier = "Carrier"
    case battleship = "Battleship"
    case cruiser = "Cruiser"
    case submarine = "Submarine"
    case destroyer = "Destroyer"
    
    var length: Int {
        switch self {
        case .carrier: return 5
        case .battleship: return 4
        case .cruiser: return 3
        case .submarine: return 3
        case .destroyer: return 2
        }
    }
}

struct Ship: Identifiable, Codable {
    
    // MARK: - Stored properties
    let id = UUID()
    let type: ShipType
    var coordinates: [Coordinate]
    var hits: [Coordinate] = []
    
    // MARK: - Computed properties
    var isSunk: Bool {
        return hits.count == type.length
    }
    
    // MARK: - Initializer
    init(type: ShipType, coordinates: [Coordinate]) {
        self.type = type
        self.coordinates = coordinates
    }
    
    // MARK: - Functions
    
    // Record a hit if the coordinate matches one of the ship's coordinates
    mutating func takeHit(at coordinate: Coordinate) -> Bool {
        for shipCoordinate in coordinates {
            if shipCoordinate == coordinate {
                // Check if this coordinate was already hit
                var alreadyHit = false
                for existingHit in hits {
                    if existingHit == coordinate {
                        alreadyHit = true
                        break
                    }
                }
                
                if alreadyHit == false {
                    hits.append(coordinate)
                }
                return true
            }
        }
        return false
    }
}
