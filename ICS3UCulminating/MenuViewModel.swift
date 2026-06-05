import Foundation
import Observation

enum AppState {
    case menu
    case gameplay
}

@Observable
class MenuViewModel {
    
    // MARK: - Stored properties
    
    var appState: AppState = .menu
    
    // MARK: - Initializer
    
    init() {}
    
    // MARK: - Functions
    
    func startGame() {
        appState = .gameplay
    }
    
    func goToMenu() {
        appState = .menu
    }
}
