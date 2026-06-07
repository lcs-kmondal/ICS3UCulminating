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
    
    // AI targeting memory
    private var aiTargetQueue: [Coordinate] = []
    
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
        
        var targetCoord: Coordinate?
        
        // 1. Try to pull a target from the queue (Hunting mode)
        while !aiTargetQueue.isEmpty {
            let potentialTarget = aiTargetQueue.removeFirst()
            // Check if we already fired here
            if playerBoard.grid[potentialTarget.row][potentialTarget.column] == .empty {
                targetCoord = potentialTarget
                break
            }
        }
        
        // 2. If no valid target in queue, pick randomly (Scanning mode)
        if targetCoord == nil {
            var shotTaken = false
            while !shotTaken {
                let row = Int.random(in: 0..<10)
                let col = Int.random(in: 0..<10)
                let coord = Coordinate(row: row, column: col)
                
                if playerBoard.grid[row][col] == .empty {
                    targetCoord = coord
                    shotTaken = true
                }
            }
        }
        
        // 3. Execute the shot
        if let coord = targetCoord {
            let wasHit = playerBoard.receiveFire(at: coord)
            
            // 4. If it was a hit, add neighbors to the queue
            if wasHit {
                addNeighborsToTargetQueue(around: coord)
            }
        }
        
        if playerBoard.allShipsSunk() {
            phase = .gameOver
            winner = "Computer"
        } else {
            isPlayerTurn = true
        }
    }
    
    private func addNeighborsToTargetQueue(around coordinate: Coordinate) {
        let offsets = [(-1, 0), (1, 0), (0, -1), (0, 1)] // Up, Down, Left, Right
        
        for offset in offsets {
            let newRow = coordinate.row + offset.0
            let newCol = coordinate.column + offset.1
            
            // Check bounds
            if newRow >= 0 && newRow < 10 && newCol >= 0 && newCol < 10 {
                let neighbor = Coordinate(row: newRow, column: newCol)
                // Only add if we haven't fired there yet
                if playerBoard.grid[newRow][newCol] == .empty {
                    // Check if it's already in the queue to avoid duplicates
                    var alreadyInQueue = false
                    for existing in aiTargetQueue {
                        if existing.row == neighbor.row && existing.column == neighbor.column {
                            alreadyInQueue = true
                            break
                        }
                    }
                    
                    if !alreadyInQueue {
                        aiTargetQueue.append(neighbor)
                    }
                }
            }
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
        aiTargetQueue = []
        autoSetupComputerBoard()
    }
}
