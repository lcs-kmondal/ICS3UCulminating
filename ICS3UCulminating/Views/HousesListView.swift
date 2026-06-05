//
//  HousesListView.swift
//  ICS3UCulminating
//
//  Created by Xavier Mondal on 2026-06-01.
//

import SwiftUI
 
// VIEW
struct HousesListView: View {
    
    // MARK: Stored properties
    // Stored properties must be provided with a value by providing an argument when creating an instance of this structure, or, be initialized with a default value
    
    // Holds the view model, to track current state of
    // data within the app
    @State var viewModel = HouseListViewModel()
    
    // MARK: Computed properties
    // Computed properties calculate or derive a value using stored properties
    
    // The "body" property defines the user interface for this app
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: BattleshipGameView()) {
                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(.red)
                        Text("Play Battleship")
                            .font(.headline)
                    }
                    .padding(.vertical, 8)
                }

                Section("LCS Houses") {
                    ForEach(viewModel.housesList) { currentHouse in
                        HouseItemView(providedHouse: currentHouse)
                    }
                }
            }
            .navigationTitle("LCS Houses")
        }
    }
}
 
#Preview {
    HousesListView()
}
