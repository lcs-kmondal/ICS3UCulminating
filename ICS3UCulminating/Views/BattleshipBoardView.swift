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
    let onCellTap: (Coordinate) -> Void
    
    // MARK: - Body
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
            
            VStack(spacing: 2) {
                // Header row (numbers 1-10)
                HStack(spacing: 2) {
                    Spacer().frame(width: 25)
                    ForEach(1...10, id: \.self) { i in
                        Text("\(i)")
                            .frame(width: 30, height: 30)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Grid rows
                ForEach(0..<10, id: \.self) { row in
                    HStack(spacing: 2) {
                        // Label (A-J)
                        Text(String(UnicodeScalar(65 + row)!))
                            .frame(width: 25, height: 30)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        ForEach(0..<10, id: \.self) { col in
                            CellView(
                                state: board.grid[row][col],
                                hasShip: board.isOccupied(at: Coordinate(row: row, column: col)),
                                isInteractive: isInteractive
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
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(backgroundColor)
                .frame(width: 30, height: 30)
                .border(Color.blue.opacity(0.2), width: 0.5)
            
            if state == .hit {
                Circle()
                    .fill(Color.red)
                    .frame(width: 15, height: 15)
            } else if state == .miss {
                Circle()
                    .fill(Color.white)
                    .frame(width: 10, height: 10)
            } else if hasShip && !isInteractive {
                // Only show ships on the player's own board (where interaction is usually disabled for the board itself during firing)
                // Or if we want to show ships during placement
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray)
                    .padding(4)
            }
        }
    }
    
    private var backgroundColor: Color {
        switch state {
        case .empty:
            return Color.blue.opacity(0.1)
        case .hit:
            return Color.blue.opacity(0.2)
        case .miss:
            return Color.blue.opacity(0.05)
        }
    }
}
