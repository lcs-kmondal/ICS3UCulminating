//
//  BattleshipBoardView.swift
//  ICS3UCulminating
//

import SwiftUI

struct BattleshipBoardView: View {
    
    // MARK: - Stored properties
    var board: Board
    let title: String
    let isInteractive: Bool
    let showShips: Bool
    let onCellTap: (Coordinate) -> Void
    
    // MARK: - Initializer
    init(board: Board, 
         title: String, 
         isInteractive: Bool, 
         showShips: Bool = true, 
         onCellTap: @escaping (Coordinate) -> Void) {
        self.board = board
        self.title = title
        self.isInteractive = isInteractive
        self.showShips = showShips
        self.onCellTap = onCellTap
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
            
            VStack(spacing: 2) {
                // Grid rows
                ForEach(0..<10, id: \.self) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<10, id: \.self) { col in
                            CellView(
                                state: board.grid[row][col],
                                hasShip: board.isOccupied(at: Coordinate(row: row, column: col)),
                                isInteractive: isInteractive,
                                showShips: showShips
                            )
                            .onTapGesture {
                                if isInteractive {
                                    onCellTap(Coordinate(row: row, column: col))
                                }
                            }
                        }
                    }
                }
            }
            .padding(5)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct CellView: View {
    let state: CellState
    let hasShip: Bool
    let isInteractive: Bool
    let showShips: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(backgroundColor)
                .frame(width: 25, height: 25)
                .border(Color.blue.opacity(0.2), width: 0.5)
            
            if state == .hit {
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .foregroundColor(.red)
                    .fontWeight(.bold)
            } else if state == .miss {
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var backgroundColor: Color {
        if showShips && hasShip && (state == .empty || state == .hit) {
            return Color.gray.opacity(0.8)
        }
        
        switch state {
        case .empty:
            return Color.blue.opacity(0.1)
        case .hit:
            return Color.red.opacity(0.1)
        case .miss:
            return Color.blue.opacity(0.05)
        }
    }
}
