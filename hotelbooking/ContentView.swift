import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Hotel Booking")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Welcome! Replace this with your app's main view.")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

#Preview {
    ContentView()
}
