import SwiftUI

struct MainMenuView: View {
    
    // MARK: - Stored properties
    
    var viewModel: MenuViewModel
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 40) {
            Text("BATTLESHIP")
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(.blue)
            
            Button(action: {
                viewModel.startGame()
            }) {
                Text("Start Game")
                    .font(.headline)
                    .padding()
                    .frame(width: 200)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Text("Sink all enemy ships to win!")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
    }
}
