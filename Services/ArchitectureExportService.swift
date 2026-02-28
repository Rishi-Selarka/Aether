import SwiftUI
import UIKit
import PDFKit
import FoundationModels

// MARK: - AI-Generated Design Guide Content

@available(iOS 26, *)
@Generable
struct DesignGuideSection {
    @Guide(description: "Section heading (3-6 words)")
    var heading: String

    @Guide(description: "2-4 paragraph educational explanation for this section. Teach the student how and why this part of the system works. Be specific to the problem context.")
    var body: String
}

@available(iOS 26, *)
@Generable
struct DesignGuide {
    @Guide(description: "A 2-3 sentence overview of the system design approach for this problem")
    var overview: String

    @Guide(description: "4-6 sections covering: why each component is needed, how data flows between them, key design principles applied, tradeoffs considered, and implementation tips. Each section should teach the student something concrete about designing this system.")
    var sections: [DesignGuideSection]

    @Guide(description: "A 1-2 sentence key takeaway or design principle the student should remember")
    var keyTakeaway: String
}

// MARK: - Service

/// Builds a PDF with system design info and an AI-generated "How to Design" guide,
/// then presents the native share sheet.
enum ArchitectureExportService {

    // MARK: - Public API

    /// Generates design guide via Foundation Models, builds PDF, and presents share sheet.
    @MainActor
    static func exportAndShare(
        session: QuizSession,
        tierName: String,
        presentingFrom sourceView: UIView? = nil,
        onComplete: (() -> Void)? = nil
    ) async {
        let problem = session.problem

        guard let cardImage = renderCardImage(
            problemTitle: problem.title,
            tierName: tierName,
            blocks: problem.blocks
        ) else {
            onComplete?()
            return
        }

        // Generate design guide with Foundation Models
        let designGuide = await generateDesignGuide(problem: problem, tierName: tierName)

        guard let pdfData = buildPDF(
            problem: problem,
            tierName: tierName,
            cardImage: cardImage,
            designGuide: designGuide
        ) else {
            onComplete?()
            return
        }

        let filename = sanitizedFilename(from: problem.title)
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(filename)
            .appendingPathExtension("pdf")

        do {
            try pdfData.write(to: tempURL, options: .atomic)
        } catch {
            onComplete?()
            return
        }

        presentShareSheet(with: tempURL, sourceView: sourceView, onComplete: onComplete)
    }

    // MARK: - AI Design Guide Generation

    private static func generateDesignGuide(
        problem: InteriorProblem,
        tierName: String
    ) async -> DesignGuideContent {
        guard #available(iOS 26, *) else {
            return buildFallbackGuide(problem: problem)
        }

        return await generateWithFoundationModels(problem: problem, tierName: tierName)
    }

    @available(iOS 26, *)
    private static func generateWithFoundationModels(
        problem: InteriorProblem,
        tierName: String
    ) async -> DesignGuideContent {
        guard SystemLanguageModel.default.isAvailable else {
            return buildFallbackGuide(problem: problem)
        }

        let patternText = problem.blocks.map(\.displayName).joined(separator: " → ")
        let componentRoles = problem.blocks.map { block in
            "• \(block.displayName): \(block.architectureRole)"
        }.joined(separator: "\n")

        let prompt = """
        You are writing a "How to Design This System" educational guide for a student \
        learning iOS system design.

        Problem: \(problem.title)
        Description: \(problem.description)
        Tier: \(tierName)
        Concepts: \(problem.keywords.joined(separator: ", "))
        Architecture pattern: \(patternText)
        Components and their roles:
        \(componentRoles)

        Write a comprehensive guide teaching the student HOW to design this system \
        from scratch. Explain the reasoning behind each architectural decision, how \
        the components connect and why, what design principles apply, and practical \
        implementation considerations for iOS/Swift.

        Be educational, specific to this problem (not generic), and assume the reader \
        is a student who understands basic Swift but is learning architecture.
        """

        do {
            let session = LanguageModelSession(
                instructions: """
                You are an expert iOS system design educator. Write clear, educational \
                content that teaches students how to architect real iOS applications. \
                Be specific, practical, and reference real iOS frameworks and patterns. \
                Use concrete examples tied to the problem being discussed.
                """
            )
            let response = try await session.respond(to: prompt, generating: DesignGuide.self)
            let guide = response.content

            return DesignGuideContent(
                overview: guide.overview,
                sections: guide.sections.map { section in
                    DesignGuideContent.Section(
                        heading: section.heading,
                        body: section.body
                    )
                },
                keyTakeaway: guide.keyTakeaway
            )
        } catch {
            return buildFallbackGuide(problem: problem)
        }
    }

    /// Fallback when Foundation Models are unavailable.
    private static func buildFallbackGuide(problem: InteriorProblem) -> DesignGuideContent {
        let patternText = problem.blocks.map(\.displayName).joined(separator: " → ")

        let sections = problem.blocks.map { block in
            DesignGuideContent.Section(
                heading: "Why \(block.displayName)?",
                body: "\(block.architectureRole). In the context of \(problem.title), this component is essential for maintaining clean separation of concerns and ensuring the system remains maintainable as it grows."
            )
        }

        return DesignGuideContent(
            overview: "This guide walks through the architectural decisions behind \(problem.title). The system uses the pattern: \(patternText). Each component has a specific responsibility that keeps the codebase organized and testable.",
            sections: sections,
            keyTakeaway: "Good architecture separates concerns so each component can be understood, tested, and modified independently."
        )
    }

    // MARK: - Card Rendering

    @MainActor
    private static func renderCardImage(
        problemTitle: String,
        tierName: String,
        blocks: [NodeType]
    ) -> UIImage? {
        let cardView = ArchitectureExportCardView(
            problemTitle: problemTitle,
            tierName: tierName,
            blocks: blocks
        )

        let renderer = ImageRenderer(content: cardView)
        renderer.scale = 3.0
        if let uiImage = renderer.uiImage { return uiImage }
        if let cgImage = renderer.cgImage { return UIImage(cgImage: cgImage) }
        return nil
    }

    // MARK: - PDF Generation

    private static func buildPDF(
        problem: InteriorProblem,
        tierName: String,
        cardImage: UIImage,
        designGuide: DesignGuideContent
    ) -> Data? {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // US Letter
        let margin: CGFloat = 48
        let contentWidth = pageRect.width - margin * 2
        let footerText = "Generated by archsys"

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let data = pdfRenderer.pdfData { ctx in

            // --- PAGE 1: System Design Overview ---

            ctx.beginPage()
            var yOffset: CGFloat = margin

            // Title
            yOffset = drawText(
                problem.title,
                in: pageRect,
                at: yOffset,
                margin: margin,
                font: .systemFont(ofSize: 26, weight: .bold),
                color: .black
            )
            yOffset += 4

            // Tier subtitle
            yOffset = drawText(
                tierName,
                in: pageRect,
                at: yOffset,
                margin: margin,
                font: .systemFont(ofSize: 14, weight: .medium),
                color: .darkGray
            )
            yOffset += 16

            // Separator
            yOffset = drawSeparator(in: pageRect, at: yOffset, margin: margin)
            yOffset += 14

            // Problem brief
            yOffset = drawSectionHeader(
                "📋  Problem Brief",
                in: pageRect, at: yOffset, margin: margin
            )
            yOffset += 6
            yOffset = drawText(
                problem.description,
                in: pageRect,
                at: yOffset,
                margin: margin,
                font: .systemFont(ofSize: 13),
                color: .darkGray
            )
            yOffset += 18

            // Concepts
            yOffset = drawSectionHeader(
                "💡  Key Concepts",
                in: pageRect, at: yOffset, margin: margin
            )
            yOffset += 6
            for keyword in problem.keywords {
                yOffset = drawText(
                    "•  \(keyword)",
                    in: pageRect,
                    at: yOffset,
                    margin: margin + 12,
                    font: .systemFont(ofSize: 13),
                    color: .darkGray
                )
                yOffset += 2
            }
            yOffset += 16

            // Architecture pattern
            let patternText = problem.blocks.map(\.displayName).joined(separator: " → ")
            yOffset = drawSectionHeader(
                "🏗️  Architecture Pattern",
                in: pageRect, at: yOffset, margin: margin
            )
            yOffset += 6
            yOffset = drawText(
                patternText,
                in: pageRect,
                at: yOffset,
                margin: margin,
                font: .monospacedSystemFont(ofSize: 12, weight: .medium),
                color: UIColor(red: 0.2, green: 0.2, blue: 0.55, alpha: 1)
            )
            yOffset += 8

            // Component roles
            for block in problem.blocks {
                yOffset = checkPageBreak(
                    ctx: ctx,
                    yOffset: yOffset,
                    needed: 30,
                    pageRect: pageRect,
                    margin: margin
                )
                yOffset = drawText(
                    "▸ \(block.displayName) — \(block.architectureRole)",
                    in: pageRect,
                    at: yOffset,
                    margin: margin + 12,
                    font: .systemFont(ofSize: 11),
                    color: UIColor(white: 0.35, alpha: 1)
                )
                yOffset += 4
            }
            yOffset += 20

            // Card image
            let cardAspect = cardImage.size.height / max(cardImage.size.width, 1)
            let cardDrawWidth = min(contentWidth, 380)
            let cardDrawHeight = cardDrawWidth * cardAspect
            let cardX = margin + (contentWidth - cardDrawWidth) / 2

            yOffset = checkPageBreak(
                ctx: ctx,
                yOffset: yOffset,
                needed: cardDrawHeight + 20,
                pageRect: pageRect,
                margin: margin
            )

            let cardRect = CGRect(
                x: cardX, y: yOffset,
                width: cardDrawWidth, height: cardDrawHeight
            )
            cardImage.draw(in: cardRect)
            yOffset += cardDrawHeight + 12

            // Page 1 footer
            drawFooter(footerText, in: pageRect, margin: margin)

            // --- PAGE 2+: How to Design This System ---

            ctx.beginPage()
            yOffset = margin

            yOffset = drawText(
                "How to Design This System",
                in: pageRect,
                at: yOffset,
                margin: margin,
                font: .systemFont(ofSize: 22, weight: .bold),
                color: .black
            )
            yOffset += 4

            yOffset = drawText(
                problem.title,
                in: pageRect,
                at: yOffset,
                margin: margin,
                font: .systemFont(ofSize: 13, weight: .medium),
                color: .darkGray
            )
            yOffset += 14

            yOffset = drawSeparator(in: pageRect, at: yOffset, margin: margin)
            yOffset += 16

            // Overview
            yOffset = drawSectionHeader(
                "🎯  Overview",
                in: pageRect, at: yOffset, margin: margin
            )
            yOffset += 6
            yOffset = drawText(
                designGuide.overview,
                in: pageRect,
                at: yOffset,
                margin: margin,
                font: .systemFont(ofSize: 13),
                color: UIColor(white: 0.25, alpha: 1)
            )
            yOffset += 20

            // Design guide sections
            let sectionIcons = ["🔧", "📐", "🔄", "⚙️", "🧩", "🛡️"]
            for (index, section) in designGuide.sections.enumerated() {
                let icon = sectionIcons[index % sectionIcons.count]

                // Check if we need a new page (estimate header + some body)
                yOffset = checkPageBreak(
                    ctx: ctx,
                    yOffset: yOffset,
                    needed: 60,
                    pageRect: pageRect,
                    margin: margin
                )

                yOffset = drawSectionHeader(
                    "\(icon)  \(section.heading)",
                    in: pageRect, at: yOffset, margin: margin
                )
                yOffset += 6

                // Draw body text, breaking across pages if needed
                yOffset = drawLongText(
                    section.body,
                    ctx: ctx,
                    pageRect: pageRect,
                    yOffset: yOffset,
                    margin: margin,
                    font: .systemFont(ofSize: 12),
                    color: UIColor(white: 0.3, alpha: 1)
                )
                yOffset += 18
            }

            // Key takeaway box
            yOffset = checkPageBreak(
                ctx: ctx,
                yOffset: yOffset,
                needed: 80,
                pageRect: pageRect,
                margin: margin
            )
            yOffset += 8
            yOffset = drawTakeawayBox(
                designGuide.keyTakeaway,
                in: pageRect,
                at: yOffset,
                margin: margin
            )

            // Final footer
            drawFooter(footerText, in: pageRect, margin: margin)
        }

        return data
    }

    // MARK: - PDF Drawing Helpers

    private static func drawText(
        _ text: String,
        in pageRect: CGRect,
        at yOffset: CGFloat,
        margin: CGFloat,
        font: UIFont,
        color: UIColor
    ) -> CGFloat {
        let contentWidth = pageRect.width - margin * 2
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        let textRect = CGRect(
            x: margin, y: yOffset,
            width: contentWidth, height: .greatestFiniteMagnitude
        )
        let boundingRect = (text as NSString).boundingRect(
            with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        (text as NSString).draw(
            with: textRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        return yOffset + ceil(boundingRect.height)
    }

    /// Draws long text that may span multiple pages.
    private static func drawLongText(
        _ text: String,
        ctx: UIGraphicsPDFRendererContext,
        pageRect: CGRect,
        yOffset: CGFloat,
        margin: CGFloat,
        font: UIFont,
        color: UIColor
    ) -> CGFloat {
        let contentWidth = pageRect.width - margin * 2
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]

        // Split text into paragraphs for page-break handling
        let paragraphs = text.components(separatedBy: "\n\n")
        var currentY = yOffset

        for (i, paragraph) in paragraphs.enumerated() {
            let trimmed = paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            let boundingRect = (trimmed as NSString).boundingRect(
                with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: attributes,
                context: nil
            )
            let textHeight = ceil(boundingRect.height)

            currentY = checkPageBreak(
                ctx: ctx,
                yOffset: currentY,
                needed: min(textHeight, 40),
                pageRect: pageRect,
                margin: margin
            )

            let textRect = CGRect(
                x: margin, y: currentY,
                width: contentWidth, height: textHeight + 4
            )
            (trimmed as NSString).draw(
                with: textRect,
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: attributes,
                context: nil
            )
            currentY += textHeight

            if i < paragraphs.count - 1 {
                currentY += 8
            }
        }

        return currentY
    }

    private static func drawSectionHeader(
        _ text: String,
        in pageRect: CGRect,
        at yOffset: CGFloat,
        margin: CGFloat
    ) -> CGFloat {
        drawText(
            text,
            in: pageRect,
            at: yOffset,
            margin: margin,
            font: .systemFont(ofSize: 15, weight: .semibold),
            color: .black
        )
    }

    private static func drawSeparator(
        in pageRect: CGRect,
        at yOffset: CGFloat,
        margin: CGFloat
    ) -> CGFloat {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: margin, y: yOffset))
        path.addLine(to: CGPoint(x: pageRect.width - margin, y: yOffset))
        UIColor.lightGray.setStroke()
        path.lineWidth = 0.5
        path.stroke()
        return yOffset + 1
    }

    /// Draws a highlighted takeaway box with rounded background.
    private static func drawTakeawayBox(
        _ text: String,
        in pageRect: CGRect,
        at yOffset: CGFloat,
        margin: CGFloat
    ) -> CGFloat {
        let contentWidth = pageRect.width - margin * 2
        let boxPadding: CGFloat = 16
        let innerWidth = contentWidth - boxPadding * 2

        let labelFont = UIFont.systemFont(ofSize: 12, weight: .bold)
        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: labelFont,
            .foregroundColor: UIColor(red: 0.15, green: 0.4, blue: 0.15, alpha: 1)
        ]
        let labelHeight: CGFloat = 18

        let bodyFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        let bodyAttrs: [NSAttributedString.Key: Any] = [
            .font: bodyFont,
            .foregroundColor: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        ]
        let bodyBounds = (text as NSString).boundingRect(
            with: CGSize(width: innerWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: bodyAttrs,
            context: nil
        )
        let bodyHeight = ceil(bodyBounds.height)
        let boxHeight = boxPadding + labelHeight + 4 + bodyHeight + boxPadding

        // Draw box background
        let boxRect = CGRect(x: margin, y: yOffset, width: contentWidth, height: boxHeight)
        let boxPath = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor(red: 0.92, green: 0.97, blue: 0.92, alpha: 1).setFill()
        boxPath.fill()
        UIColor(red: 0.7, green: 0.85, blue: 0.7, alpha: 1).setStroke()
        boxPath.lineWidth = 1
        boxPath.stroke()

        // Draw label
        ("💡 Key Takeaway" as NSString).draw(
            at: CGPoint(x: margin + boxPadding, y: yOffset + boxPadding),
            withAttributes: labelAttrs
        )

        // Draw body
        let bodyRect = CGRect(
            x: margin + boxPadding,
            y: yOffset + boxPadding + labelHeight + 4,
            width: innerWidth,
            height: bodyHeight + 4
        )
        (text as NSString).draw(
            with: bodyRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: bodyAttrs,
            context: nil
        )

        return yOffset + boxHeight
    }

    /// Starts a new page if remaining space is insufficient.
    private static func checkPageBreak(
        ctx: UIGraphicsPDFRendererContext,
        yOffset: CGFloat,
        needed: CGFloat,
        pageRect: CGRect,
        margin: CGFloat
    ) -> CGFloat {
        let footerReserve: CGFloat = 40
        if yOffset + needed + footerReserve > pageRect.height - margin {
            drawFooter("Generated by archsys", in: pageRect, margin: margin)
            ctx.beginPage()
            return margin
        }
        return yOffset
    }

    @discardableResult
    private static func drawFooter(
        _ text: String,
        in pageRect: CGRect,
        margin: CGFloat
    ) -> CGFloat {
        let footerFont = UIFont.systemFont(ofSize: 10, weight: .medium)
        let footerAttr: [NSAttributedString.Key: Any] = [
            .font: footerFont,
            .foregroundColor: UIColor.lightGray
        ]
        let footerSize = (text as NSString).size(withAttributes: footerAttr)
        let footerY = pageRect.height - margin + 10
        let footerX = (pageRect.width - footerSize.width) / 2
        (text as NSString).draw(
            at: CGPoint(x: footerX, y: footerY),
            withAttributes: footerAttr
        )
        return footerY
    }

    // MARK: - Filename Sanitization

    private static func sanitizedFilename(from title: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(.init(charactersIn: " -"))
        let cleaned = title
            .unicodeScalars
            .filter { allowed.contains($0) }
            .map { Character($0) }
        return String(cleaned)
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: " ", with: "_")
            + "_arch"
    }

    // MARK: - Share Sheet

    @MainActor
    private static func presentShareSheet(
        with url: URL,
        sourceView: UIView?,
        onComplete: (() -> Void)?
    ) {
        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )

        activityVC.completionWithItemsHandler = { _, _, _, _ in
            Task { @MainActor in onComplete?() }
        }

        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene }).first,
              let rootVC = windowScene.keyWindow?.rootViewController
        else {
            onComplete?()
            return
        }

        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        if let anchorView = sourceView ?? topVC.view,
           let popover = activityVC.popoverPresentationController {
            popover.sourceView = anchorView
            popover.sourceRect = anchorView.bounds
        }

        topVC.present(activityVC, animated: true)
    }
}

// MARK: - Design Guide Content (Platform-agnostic)

/// Holds the AI-generated or fallback design guide content for PDF rendering.
struct DesignGuideContent {
    struct Section {
        let heading: String
        let body: String
    }

    let overview: String
    let sections: [Section]
    let keyTakeaway: String
}
