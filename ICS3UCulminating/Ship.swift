import Foundation

struct Ship: Equatable {
    
    // MARK: - Stored properties
    
    let type: ShipType
    var coordinates: [Coordinate]
    var hits: [Coordinate]
    
    // MARK: - Computed properties
    
    var isSunk: Bool {
        return hits.count == coordinates.count
    }
    
    // MARK: - Initializer
    
    init(type: ShipType, coordinates: [Coordinate]) {
        self.type = type
        self.coordinates = coordinates
        self.hits = []
    }
    
    // MARK: - Functions
    
    mutating func registerHit(at coordinate: Coordinate) {
        var alreadyHit: Bool = false
        for hit in hits {
            if hit == coordinate {
                alreadyHit = true
            }
        }
        
        if alreadyHit == false {
            hits.append(coordinate)
        }
    }
}
