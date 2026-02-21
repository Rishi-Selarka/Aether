import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var progressRecords: [CityProgress]
    
    @State private var showSplash = true
    
    var progress: CityProgress? {
        progressRecords.first
    }
    
    var body: some View {
        Group {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                if let progress {
                    TierMapView(progress: progress)
                        .transition(.opacity)
                } else {
                    ProgressView("Loading City Architect...")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.archsysBackground)
        .onAppear {
            SwiftDataManager.initializeIfNeeded(context: modelContext)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showSplash = false
                }
            }
        }
    }
}

struct TierMapView: View {
    let progress: CityProgress
    
    var body: some View {
        ScrollView {
            VStack(spacing: LayoutConstants.spacingL) {
                Text("City Architect")
                    .font(.largeTitle.bold())
                    .foregroundColor(.archsysTextPrimary)
                
                Text("Build Mobile Architectures, Visually")
                    .font(.title3)
                    .foregroundColor(.archsysTextSecondary)
                
                ForEach(progress.tiers.sorted(by: { $0.id < $1.id }), id: \.id) { tier in
                    TierCardView(tier: tier)
                }
            }
            .padding(LayoutConstants.spacingL)
        }
        .background(Color.archsysBackground)
    }
}

struct TierCardView: View {
    let tier: Tier
    
    var body: some View {
        HStack(spacing: LayoutConstants.spacingM) {
            Image(systemName: tierIcon)
                .font(.system(size: 48))
                .foregroundColor(tier.unlocked ? .blue : .gray)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Tier \(tier.id): \(tier.name)")
                    .font(.headline)
                    .foregroundColor(.archsysTextPrimary)
                
                Text(tier.unlocked ? (tier.completed ? "Completed" : "In Progress") : "Locked")
                    .font(.caption)
                    .foregroundColor(.archsysTextSecondary)
            }
            
            Spacer()
            
            if tier.unlocked {
                Image(systemName: tier.completed ? "checkmark.circle.fill" : "play.circle.fill")
                    .foregroundColor(tier.completed ? .green : .blue)
            } else {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding(LayoutConstants.spacingM)
        .background(Color.archsysSurface)
        .cornerRadius(LayoutConstants.cornerRadiusM)
        .opacity(tier.unlocked ? 1 : 0.6)
    }
    
    private var tierIcon: String {
        switch tier.id {
        case 1: return "building.2"
        case 2: return "network"
        case 3: return "bolt.fill"
        case 4: return "shield.fill"
        case 5: return "brain.head.profile"
        default: return "square.grid.2x2"
        }
    }
}
