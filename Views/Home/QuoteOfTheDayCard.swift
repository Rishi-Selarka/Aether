import SwiftUI

/// Displays the daily AI-generated quote with a left accent rule.
struct QuoteOfTheDayCard: View {
    let quote: DailyQuote?

    var body: some View {
        Group {
            if let quote {
                loadedContent(quote)
            } else {
                placeholder
            }
        }
    }

    private func loadedContent(_ quote: DailyQuote) -> some View {
        HStack(alignment: .top, spacing: 14) {
            // Left accent rule
            RoundedRectangle(cornerRadius: 1.5)
                .fill(Color.homeAccent)
                .frame(width: 3)
                .padding(.vertical, 2)

            VStack(alignment: .leading, spacing: 8) {
                Text(quote.text)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.aetherTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)

                Text("— \(quote.attribution)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.aetherTextTertiary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.aetherSurface, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.aetherBorder, lineWidth: 0.5)
        }
    }

    private var placeholder: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 1.5)
                .fill(Color.aetherBorder)
                .frame(width: 3, height: 40)

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.aetherSurface)
                    .frame(height: 14)
                    .frame(maxWidth: 240)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.aetherSurface)
                    .frame(height: 14)
                    .frame(maxWidth: 160)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.aetherSurface, in: RoundedRectangle(cornerRadius: 14))
    }
}
