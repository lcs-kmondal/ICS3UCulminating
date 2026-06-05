import SwiftUI

struct GridView: View {
    
    // MARK: - Stored properties
    
    var grid: Grid
    var isOffense: Bool
    var onCellTap: (Coordinate) -> Void
    
    // MARK: - Computed properties
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]
    
    // MARK: - Body
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 1) {
            ForEach(0..<100, id: \.self) { index in
                let row: Int = index / 10
                let column: Int = index % 10
                let cellState = grid.cells[row][column]
                let coordinate = Coordinate(row: row, column: column)
                
                CellView(state: cellState, isOffense: isOffense)
                    .aspectRatio(1, contentMode: .fit)
                    .onTapGesture {
                        onCellTap(coordinate)
                    }
            }
        }
        .background(Color.gray)
        .border(Color.black, width: 2)
    }
}

struct CellView: View {
    var state: CellState
    var isOffense: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(colorForState)
            
            if case .hit = state {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
            } else if case .miss = state {
                Circle()
                    .fill(Color.white)
                    .frame(width: 10, height: 10)
            }
        }
    }
    
    var colorForState: Color {
        switch state {
        case .empty:
            return Color.blue.opacity(0.3)
        case .ship:
            return isOffense ? Color.blue.opacity(0.3) : Color.gray
        case .hit:
            return Color.red
        case .miss:
            return Color.blue.opacity(0.6)
        }
    }
}
