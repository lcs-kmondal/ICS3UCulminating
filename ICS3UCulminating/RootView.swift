import SwiftUI

struct RootView: View {
    
    // MARK: - Stored properties
    
    @State private var menuViewModel: MenuViewModel = MenuViewModel()
    @State private var gameplayViewModel: GameplayViewModel = GameplayViewModel()
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if menuViewModel.appState == .menu {
                MainMenuView(viewModel: menuViewModel)
                    .onAppear {
                        // Reset game when returning to menu
                        gameplayViewModel = GameplayViewModel()
                    }
            } else {
                GameView(viewModel: gameplayViewModel, menuViewModel: menuViewModel)
            }
        }
    }
}
