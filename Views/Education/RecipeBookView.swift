import SwiftUI
import SwiftData

struct RecipeBookView: View {
    @Environment(\.dismiss) private var dismiss
    let tierID: Int
    let onLoadRecipe: (ArchitectureRecipe) -> Void

    private var recipes: [ArchitectureRecipe] {
        RecipeDatabase.recipes(for: tierID)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: LayoutConstants.spacingM) {
                    ForEach(recipes) { recipe in
                        RecipeCard(recipe: recipe) {
                            onLoadRecipe(recipe)
                            dismiss()
                        }
                    }
                }
                .padding(LayoutConstants.spacingM)
            }
            .background(Color.archsysBackground)
            .navigationTitle("Recipe Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct RecipeCard: View {
    let recipe: ArchitectureRecipe
    let onLoad: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.spacingS) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.name)
                        .font(Typography.headingSmall)
                        .foregroundStyle(Color.archsysTextPrimary)
                    Text(recipe.description)
                        .font(Typography.bodySmall)
                        .foregroundStyle(Color.archsysTextSecondary)
                        .lineLimit(2)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(recipe.difficulty.displayName)
                        .font(Typography.bodySmall)
                        .foregroundStyle(difficultyColor)
                    Text("Tier \(recipe.tierLevel)")
                        .font(Typography.bodySmall)
                        .foregroundStyle(Color.archsysTextTertiary)
                }
            }

            if !recipe.realWorldApps.isEmpty {
                Text("Apps: \(recipe.realWorldApps.joined(separator: ", "))")
                    .font(Typography.bodySmall)
                    .foregroundStyle(Color.archsysTextTertiary)
            }

            HStack(spacing: LayoutConstants.spacingS) {
                Label("\(recipe.nodes.count) nodes", systemImage: "square.grid.2x2")
                    .font(Typography.bodySmall)
                    .foregroundStyle(Color.archsysTextSecondary)
                Label("\(recipe.connections.count) connections", systemImage: "arrow.triangle.branch")
                    .font(Typography.bodySmall)
                    .foregroundStyle(Color.archsysTextSecondary)
            }

            Button(action: onLoad) {
                Label("Load Recipe", systemImage: "square.and.arrow.down")
                    .font(Typography.bodyMedium)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, LayoutConstants.spacingS)
                    .background(Color.green)
                    .cornerRadius(LayoutConstants.cornerRadiusS)
            }
        }
        .padding(LayoutConstants.spacingM)
        .background(Color.archsysSurface)
        .cornerRadius(LayoutConstants.cornerRadiusM)
    }

    private var difficultyColor: Color {
        switch recipe.difficulty {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}
