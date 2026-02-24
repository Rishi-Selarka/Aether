import SwiftUI

struct GlossaryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: GlossaryCategory?
    @State private var selectedTerm: GlossaryTerm?

    private var filteredTerms: [GlossaryTerm] {
        let base = selectedCategory.map { GlossaryDatabase.terms(for: $0) } ?? GlossaryDatabase.allTerms
        if searchText.isEmpty { return base }
        let searched = GlossaryDatabase.search(searchText)
        return selectedCategory.map { cat in searched.filter { $0.category == cat } } ?? searched
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                categoryFilter

                List(filteredTerms) { term in
                    Button {
                        selectedTerm = term
                    } label: {
                        GlossaryTermRow(term: term)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Glossary")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search 30+ terms")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(item: $selectedTerm) { term in
                GlossaryDetailSheet(term: term)
            }
        }
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LayoutConstants.spacingS) {
                CategoryChip(title: "All", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(GlossaryCategory.allCases, id: \.self) { category in
                    CategoryChip(title: category.displayName, isSelected: selectedCategory == category) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, LayoutConstants.spacingS)
        .background(Color.archsysSurface)
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typography.bodySmall)
                .foregroundStyle(isSelected ? .white : Color.archsysTextPrimary)
                .padding(.horizontal, LayoutConstants.spacingS)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color.archsysBackground)
                .cornerRadius(20)
        }
    }
}

struct GlossaryTermRow: View {
    let term: GlossaryTerm

    var body: some View {
        HStack(spacing: LayoutConstants.spacingS) {
            Image(systemName: term.sfSymbol)
                .foregroundStyle(categoryColor)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(term.term)
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Color.archsysTextPrimary)
                Text(term.definition)
                    .font(Typography.bodySmall)
                    .foregroundStyle(Color.archsysTextSecondary)
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color.archsysTextTertiary)
        }
        .padding(.vertical, 4)
    }

    private var categoryColor: Color {
        switch term.category {
        case .architecturePatterns: return .blue
        case .components: return .purple
        case .concepts: return .green
        case .antiPatterns: return .red
        }
    }
}

struct GlossaryDetailSheet: View {
    let term: GlossaryTerm
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LayoutConstants.spacingL) {
                    Text(term.definition)
                        .font(Typography.bodyLarge)
                        .foregroundStyle(Color.archsysTextPrimary)

                    if let code = term.codeExample, !code.isEmpty {
                        VStack(alignment: .leading, spacing: LayoutConstants.spacingS) {
                            Text("Code Example")
                                .font(Typography.headingSmall)
                                .foregroundStyle(Color.archsysTextPrimary)
                            Text(code)
                                .font(Typography.code)
                                .foregroundStyle(Color.archsysTextSecondary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.archsysBackground)
                                .cornerRadius(LayoutConstants.cornerRadiusS)
                        }
                    }

                    if !term.realWorldApps.isEmpty {
                        VStack(alignment: .leading, spacing: LayoutConstants.spacingS) {
                            Text("Real-world Apps")
                                .font(Typography.headingSmall)
                                .foregroundStyle(Color.archsysTextPrimary)
                            Text(term.realWorldApps.joined(separator: ", "))
                                .font(Typography.bodyMedium)
                                .foregroundStyle(Color.archsysTextSecondary)
                        }
                    }
                }
                .padding(LayoutConstants.spacingM)
            }
            .navigationTitle(term.term)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

extension GlossaryTerm: Hashable {
    static func == (lhs: GlossaryTerm, rhs: GlossaryTerm) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
