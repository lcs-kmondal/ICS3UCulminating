//
//  BattleshipGameView.swift
//  ICS3UCulminating
//

import SwiftUI

struct BattleshipGameView: View {
    
    // MARK: - Stored properties
    @State private var viewModel = BattleshipGame()
    @State private var selectedShipType: ShipType? = .carrier
    @State private var isVertical: Bool = true
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text("Battleship")
                    .font(.title.bold())
                    .padding(.top)
                
                if viewModel.phase == .setup {
                    setupView
                } else if viewModel.phase == .playing {
                    gameplayView
                } else {
                    gameOverView
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Game")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Setup View
    private var setupView: some View {
        VStack(spacing: 10) {
            Text("Place Your Ships")
                .font(.headline)
            
            Button(action: {
                viewModel.startGame()
            }) {
                Text("Start Game")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(viewModel.playerBoard.ships.count == 5 ? Color.green : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(viewModel.playerBoard.ships.count < 5)
            
            BattleshipBoardView(
                board: viewModel.playerBoard,
                title: "Your Board",
                isInteractive: true,
                onCellTap: handlePlacement
            )
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Boat Legend & Selection:")
                        .font(.headline)
                    Spacer()
                    Toggle("Vertical", isOn: $isVertical)
                        .labelsHidden()
                    Text("Vertical")
                        .font(.caption)
                }
                
                ForEach(ShipType.allCases, id: \.self) { type in
                    Button(action: {
                        selectedShipType = type
                    }) {
                        HStack {
                            Text(type.rawValue)
                                .frame(width: 80, alignment: .leading)
                            
                            HStack(spacing: 2) {
                                ForEach(0..<type.length, id: \.self) { _ in
                                    Rectangle()
                                        .fill(selectedShipType == type ? Color.blue : Color.gray.opacity(0.5))
                                        .frame(width: 15, height: 15)
                                }
                            }
                            
                            Spacer()
                            
                            Text("\(type.length) cells")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if viewModel.playerBoard.ships.contains(where: { $0.type == type }) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(4)
                        .background(selectedShipType == type ? Color.blue.opacity(0.1) : Color.clear)
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(10)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Gameplay View
    private var gameplayView: some View {
        VStack(spacing: 30) {
            Text(viewModel.isPlayerTurn ? "Your Turn - Fire!" : "Computer's Turn...")
                .font(.title2)
                .foregroundColor(viewModel.isPlayerTurn ? .blue : .red)
            
            BattleshipBoardView(
                board: viewModel.computerBoard,
                title: "Target Grid (Opponent)",
                isInteractive: viewModel.isPlayerTurn,
                onCellTap: handleFiring
            )
            
            BattleshipBoardView(
                board: viewModel.playerBoard,
                title: "Your Fleet",
                isInteractive: false,
                onCellTap: { _ in }
            )
        }
    }
    
    // MARK: - Game Over View
    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text("Game Over")
                .font(.largeTitle)
            
            Text(viewModel.winner == "Player" ? "You Won! 🎉" : "Computer Won! 🤖")
                .font(.title)
                .foregroundColor(viewModel.winner == "Player" ? .green : .red)
            
            Button(action: {
                viewModel.reset()
            }) {
                Text("Play Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
    
    // MARK: - Functions
    
    private func handlePlacement(at coordinate: Coordinate) {
        guard let type = selectedShipType else { return }
        
        // Check if ship of this type is already placed
        var alreadyPlaced = false
        for ship in viewModel.playerBoard.ships {
            if ship.type == type {
                alreadyPlaced = true
                break
            }
        }
        
        if alreadyPlaced {
            // Option: remove old one or just return
            return
        }
        
        if viewModel.playerBoard.canPlaceShip(type: type, at: coordinate, isVertical: isVertical) {
            viewModel.playerBoard.placeShip(type: type, at: coordinate, isVertical: isVertical)
            
            // Auto-select next ship type if available
            selectNextShipType()
        }
    }
    
    private func selectNextShipType() {
        let allTypes = ShipType.allCases
        for type in allTypes {
            var placed = false
            for ship in viewModel.playerBoard.ships {
                if ship.type == type {
                    placed = true
                    break
                }
            }
            if !placed {
                selectedShipType = type
                return
            }
        }
        selectedShipType = nil
    }
    
    private func handleFiring(at coordinate: Coordinate) {
        viewModel.playerFire(at: coordinate)
        
        if !viewModel.isPlayerTurn && viewModel.phase == .playing {
            // Trigger computer turn with a slight delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                viewModel.computerFire()
            }
        }
    }
}
