import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showOnboarding = true

    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView(onComplete: { dismissOnboarding() })
                    .transition(.opacity)
            } else {
                MainContentView()
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.clear)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
            SwiftDataManager.initializeIfNeeded(context: modelContext)
        }
    }

    private func dismissOnboarding() {
        let animation: Animation? = reduceMotion ? nil : .easeInOut(duration: 0.8)
        withAnimation(animation) {
            showOnboarding = false
        }
    }
}

struct MainContentView: View {
    var body: some View {
        NavigationStack {
            TierMapView()
        }
    }
}
