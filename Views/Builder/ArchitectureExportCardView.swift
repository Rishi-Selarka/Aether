import SwiftUI

/// A social-ready card rendered via ImageRenderer for export/sharing.
/// Shows problem title, tier, and architecture pattern diagram.
struct ArchitectureExportCardView: View {
    let problemTitle: String
    let tierName: String
    let blocks: [NodeType]

    private var nodeCount: Int { blocks.count }

    var body: some View {
        VStack(spacing: 0) {
            // Header gradient bar
            headerBar

            // Main content
            VStack(spacing: 20) {
                titleSection
                patternSection
                nodeCountBadge
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 24)

            // Footer
            footerBar
        }
        .frame(width: 480)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.10, green: 0.10, blue: 0.14),
                            Color(red: 0.06, green: 0.06, blue: 0.10)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.15), .white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        LinearGradient(
            colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.4)],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: 6)
    }

    // MARK: - Title

    private var titleSection: some View {
        VStack(spacing: 6) {
            Text(problemTitle)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text(tierName)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    // MARK: - Pattern Diagram

    private var patternSection: some View {
        VStack(spacing: 12) {
            Text("ARCHITECTURE PATTERN")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.35))
                .tracking(1.2)

            // Block flow
            HStack(spacing: 0) {
                ForEach(Array(blocks.enumerated()), id: \.offset) { index, block in
                    blockChip(block)
                    if index < blocks.count - 1 {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white.opacity(0.25))
                            .padding(.horizontal, 4)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(.white.opacity(0.04))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                }
        }
    }

    private func blockChip(_ block: NodeType) -> some View {
        VStack(spacing: 4) {
            Image(systemName: block.sfSymbol)
                .font(.system(size: 14))
                .foregroundStyle(block.accentColor)

            Text(block.displayName)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Node Count Badge

    private var nodeCountBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "square.stack.3d.up.fill")
                .font(.system(size: 12))
                .foregroundStyle(.purple.opacity(0.8))
            Text("\(nodeCount) Components")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
        }
    }

    // MARK: - Footer

    private var footerBar: some View {
        HStack {
            Image(systemName: "building.2.fill")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.3))
            Text("archsys")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.3))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.03))
    }
}
