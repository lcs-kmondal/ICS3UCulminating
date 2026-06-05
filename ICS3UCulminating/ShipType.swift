import Foundation

enum ShipType: String, CaseIterable {
    
    // MARK: - Cases
    
    case carrier = "Carrier"
    case battleship = "Battleship"
    case destroyer = "Destroyer"
    case submarine = "Submarine"
    case patrolBoat = "Patrol Boat"
    
    // MARK: - Computed properties
    
    var length: Int {
        switch self {
        case .carrier:
            return 5
        case .battleship:
            return 4
        case .destroyer:
            return 3
        case .submarine:
            return 3
        case .patrolBoat:
            return 2
        }
    }
}
