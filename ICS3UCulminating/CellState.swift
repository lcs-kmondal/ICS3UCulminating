import Foundation

enum CellState: Equatable {
    
    // MARK: - Cases
    
    case empty
    case ship(ShipType)
    case hit(ShipType)
    case miss
}
