import SwiftUI

struct GameView: View {
    
    // MARK: - Stored properties
    
    var viewModel: GameplayViewModel
    var menuViewModel: MenuViewModel
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                headerView
                
                if viewModel.phase == .placement {
                    placementView
                } else {
                    battleView(totalHeight: geometry.size.height)
                }
                
                Spacer(minLength: 0)
                
                if viewModel.gameOver {
                    gameOverButton
                }
            }
            .padding(.vertical, 10)
        }
        .animation(.default, value: viewModel.phase)
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        VStack(spacing: 5) {
            Text("BATTLESHIP")
                .font(.headline)
                .bold()
            
            Text(viewModel.statusMessage)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
        .padding(.horizontal)
    }
    
    private var placementView: some View {
        VStack(spacing: 15) {
            placementControls
            
            GridView(grid: viewModel.playerGrid, isOffense: false) { coordinate in
                viewModel.handlePlacementTap(at: coordinate)
            }
            .padding(.horizontal)
            
            Text("Tap a ship to move it")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func battleView(totalHeight: CGFloat) -> some View {
        VStack(spacing: 15) {
            // Offense Grid (Enemy)
            VStack(spacing: 5) {
                Text("Enemy Fleet (Target)")
                    .font(.caption)
                    .bold()
                GridView(grid: viewModel.aiGrid, isOffense: true) { coordinate in
                    viewModel.playerFired(at: coordinate)
                }
            }
            .padding(.horizontal)
            
            // Defense Grid (User)
            VStack(spacing: 5) {
                Text("Your Fleet (Defense)")
                    .font(.caption)
                    .bold()
                GridView(grid: viewModel.playerGrid, isOffense: false) { _ in }
                    .frame(maxWidth: 200) // Small enough to fit on screen
            }
            .padding(.horizontal)
        }
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }
    
    private var placementControls: some View {
        HStack(spacing: 20) {
            Button(action: {
                viewModel.toggleRotation()
            }) {
                Label(viewModel.isHorizontal ? "Horizontal" : "Vertical", systemImage: "rotate.right")
                    .padding(10)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            if viewModel.currentShipIndex >= viewModel.shipsToPlace.count && viewModel.selectedShipType == nil {
                Button(action: {
                    viewModel.confirmPlacement()
                }) {
                    Text("Ready to Battle")
                        .padding(10)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
    }
    
    private var gameOverButton: some View {
        Button(action: {
            menuViewModel.goToMenu()
        }) {
            Text("Return to Main Menu")
                .font(.headline)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.bottom, 20)
    }
}
