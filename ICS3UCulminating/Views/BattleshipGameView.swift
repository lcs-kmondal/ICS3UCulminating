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
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
                .opacity(0.05)
            
            ScrollView {
                VStack(spacing: viewModel.phase == .playing ? 5 : 15) {
                    if viewModel.phase != .playing {
                        Text("Battleship")
                            .font(.title.bold())
                            .padding(.top)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    
                    Group {
                        if viewModel.phase == .setup {
                            setupView
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        } else if viewModel.phase == .playing {
                            gameplayView
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        } else {
                            gameOverView
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.phase)
        .navigationTitle("Game")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Setup View
    private var setupView: some View {
        VStack(spacing: 10) {
            Text("Place Your Ships")
                .font(.headline)
            
            Text("Tap a ship to move or rotate it")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button(action: {
                withAnimation(.spring()) {
                    viewModel.startGame()
                }
            }) {
                HStack {
                    Text("Start Game")
                        .font(.headline)
                    Image(systemName: "play.fill")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(viewModel.playerBoard.ships.count == 5 ? Color.blue : Color.gray)
                        .shadow(color: viewModel.playerBoard.ships.count == 5 ? .blue.opacity(0.3) : .clear, radius: 5, x: 0, y: 3)
                )
            }
            .disabled(viewModel.playerBoard.ships.count < 5)
            
            BattleshipBoardView(
                board: viewModel.playerBoard,
                title: "Your Board",
                isInteractive: true,
                showShips: true,
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
        VStack(spacing: 12) {
            VStack(spacing: 2) {
                Text(viewModel.isPlayerTurn ? "Your Turn" : "Computer's Turn")
                    .font(.headline)
                    .foregroundColor(viewModel.isPlayerTurn ? .blue : .red)
                
                Text(viewModel.isPlayerTurn ? "Tap the grid to fire" : "Waiting for opponent...")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            BattleshipBoardView(
                board: viewModel.computerBoard,
                title: "Target Grid",
                isInteractive: viewModel.isPlayerTurn,
                showShips: false,
                onCellTap: handleFiring
            )
            .shadow(color: viewModel.isPlayerTurn ? .blue.opacity(0.1) : .clear, radius: 5)
            
            Divider()
                .padding(.horizontal, 60)
            
            BattleshipBoardView(
                board: viewModel.playerBoard,
                title: "Your Fleet",
                isInteractive: false,
                showShips: true,
                onCellTap: { _ in }
            )
            .opacity(viewModel.isPlayerTurn ? 1.0 : 0.8)
            .scaleEffect(viewModel.isPlayerTurn ? 1.0 : 0.95)
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
            
            BattleshipBoardView(
                board: viewModel.computerBoard,
                title: "Opponent's Fleet Revealed",
                isInteractive: false,
                showShips: true,
                onCellTap: { _ in }
            )
            
            HStack(spacing: 15) {
                if let jsonURL = viewModel.getJSONURL() {
                    ShareLink("Export JSON", item: jsonURL)
                        .font(.headline)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
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
        }
        .padding()
    }
    
    // MARK: - Functions
    
    private func handlePlacement(at coordinate: Coordinate) {
        // If there's a ship at this coordinate, pick it up (remove it and make it the selected type)
        if let shipAtCoord = viewModel.playerBoard.shipAt(at: coordinate) {
            selectedShipType = shipAtCoord.type
            viewModel.playerBoard.removeShip(shipAtCoord)
            return
        }
        
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
