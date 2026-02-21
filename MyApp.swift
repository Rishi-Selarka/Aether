import SwiftUI
import SwiftData

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [
            CityProgress.self,
            Tier.self,
            Architecture.self,
            ArchitectureNode.self,
            NodeConnection.self
        ])
    }
}
