//
//  BattleshipGame.swift
//  ICS3UCulminating
//

import Foundation

enum GamePhase {
    case setup
    case playing
    case gameOver
}

@Observable
class BattleshipGame {
    
    // MARK: - Stored properties
    var playerBoard: Board
    var computerBoard: Board
    var phase: GamePhase
    var isPlayerTurn: Bool
    var winner: String?
    
    // MARK: - Initializer
    init() {
        self.playerBoard = Board()
        self.computerBoard = Board()
        self.phase = .setup
        self.isPlayerTurn = true
        self.winner = nil
        
        // For now, let's auto-setup the computer's board
        autoSetupComputerBoard()
    }
    
    // MARK: - Functions
    
    // Start the game after setup
    func startGame() {
        if playerBoard.ships.count == 5 {
            phase = .playing
        }
    }
    
    // Player takes a shot
    func playerFire(at coordinate: Coordinate) {
        if phase != .playing || !isPlayerTurn { return }
        
        let _ = computerBoard.receiveFire(at: coordinate)
        
        if computerBoard.allShipsSunk() {
            phase = .gameOver
            winner = "Player"
        } else {
            isPlayerTurn = false
            // Brief delay for computer turn could be handled in the view model or view
            // For the model, we just switch turns
        }
    }
    
    // Computer takes a shot
    func computerFire() {
        if phase != .playing || isPlayerTurn { return }
        
        var shotTaken = false
        while !shotTaken {
            let row = Int.random(in: 0..<10)
            let col = Int.random(in: 0..<10)
            let coord = Coordinate(row: row, column: col)
            
            // receiveFire returns false if already fired there
            if playerBoard.grid[row][col] == .empty {
                let _ = playerBoard.receiveFire(at: coord)
                shotTaken = true
            }
        }
        
        if playerBoard.allShipsSunk() {
            phase = .gameOver
            winner = "Computer"
        } else {
            isPlayerTurn = true
        }
    }
    
    // Randomly place computer ships
    private func autoSetupComputerBoard() {
        let shipTypes = ShipType.allCases
        
        for type in shipTypes {
            var placed = false
            while !placed {
                let row = Int.random(in: 0..<10)
                let col = Int.random(in: 0..<10)
                let isVertical = Bool.random()
                let start = Coordinate(row: row, column: col)
                
                if computerBoard.canPlaceShip(type: type, at: start, isVertical: isVertical) {
                    computerBoard.placeShip(type: type, at: start, isVertical: isVertical)
                    placed = true
                }
            }
        }
    }
    
    // Reset the game
    func reset() {
        playerBoard = Board()
        computerBoard = Board()
        phase = .setup
        isPlayerTurn = true
        winner = nil
        autoSetupComputerBoard()
    }
}
