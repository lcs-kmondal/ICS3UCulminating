import Foundation

struct Coordinate: Equatable, Hashable {
    
    // MARK: - Stored properties
    
    let row: Int
    let column: Int
    
    // MARK: - Initializer
    
    init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }
}
