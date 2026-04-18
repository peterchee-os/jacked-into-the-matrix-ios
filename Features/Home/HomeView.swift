import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Jacked into the Matrix") {
                    Text("Home screen placeholder")
                }
            }
            .navigationTitle("Home")
        }
    }
}
