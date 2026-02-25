import SwiftUI

// MARK: - Bezier Curve Math

/// Cubic bezier math for organic particle paths between architecture blocks.
enum BezierMath {

    /// Returns a point along a cubic bezier curve between two endpoints.
    /// `waviness` controls lateral organic sway; `time` animates the curve shape.
    static func point(
        from: CGPoint,
        to: CGPoint,
        t: CGFloat,
        waviness: CGFloat = 0.5,
        time: Double = 0
    ) -> CGPoint {
        let midX = (from.x + to.x) / 2
        let midY = (from.y + to.y) / 2
        let dx = to.x - from.x
        let dy = to.y - from.y
        let wave = CGFloat(sin(time * 2.5 + Double(t) * .pi * 2)) * waviness * 10

        let c1 = CGPoint(x: midX + dy * 0.22 + wave, y: midY - dx * 0.12)
        let c2 = CGPoint(x: midX - dy * 0.22 - wave, y: midY + dx * 0.12)

        let mt = 1 - t
        return CGPoint(
            x: mt * mt * mt * from.x + 3 * mt * mt * t * c1.x
                + 3 * mt * t * t * c2.x + t * t * t * to.x,
            y: mt * mt * mt * from.y + 3 * mt * mt * t * c1.y
                + 3 * mt * t * t * c2.y + t * t * t * to.y
        )
    }
}

// MARK: - Multi-Layered Glow Renderer

/// Renders particles as concentric circles mimicking a radial gradient:
/// outer glow → mid halo → bright white core.
enum GlowRenderer {

    /// Draws a particle with hue-based colour (ambient / burst particles).
    static func drawDot(
        in ctx: GraphicsContext,
        at point: CGPoint,
        size: CGFloat,
        opacity: Double,
        hue: Double
    ) {
        guard opacity > 0.01 else { return }
        let color = Color(
            hue: hue.truncatingRemainder(dividingBy: 1.0),
            saturation: 0.7,
            brightness: 1.0
        )
        drawLayers(in: ctx, at: point, size: size, opacity: opacity, color: color)
    }

    /// Draws a particle using an explicit SwiftUI Color (flow / connection particles).
    static func drawDot(
        in ctx: GraphicsContext,
        at point: CGPoint,
        size: CGFloat,
        opacity: Double,
        color: Color
    ) {
        guard opacity > 0.01 else { return }
        drawLayers(in: ctx, at: point, size: size, opacity: opacity, color: color)
    }

    /// Trail behind a particle head — fading dots along the bezier path.
    static func drawTrail(
        in ctx: GraphicsContext,
        from: CGPoint,
        to: CGPoint,
        headProgress: CGFloat,
        waviness: CGFloat,
        time: Double,
        headSize: CGFloat,
        color: Color,
        count: Int = 6
    ) {
        for i in 1 ... count {
            let offset = CGFloat(i) * 0.028
            let t = max(0, headProgress - offset)
            let pos = BezierMath.point(
                from: from, to: to, t: t,
                waviness: waviness, time: time
            )
            let fade = 1.0 - Double(i) / Double(count + 1)
            let trailSize = headSize * CGFloat(max(0.3, fade))
            drawDot(in: ctx, at: pos, size: trailSize, opacity: fade * 0.45, color: color)
        }
    }

    // MARK: - Private

    private static func drawLayers(
        in ctx: GraphicsContext,
        at point: CGPoint,
        size: CGFloat,
        opacity: Double,
        color: Color
    ) {
        // Outer glow (3× size, very faint)
        let g = size * 3
        ctx.fill(
            Path(ellipseIn: CGRect(x: point.x - g / 2, y: point.y - g / 2, width: g, height: g)),
            with: .color(color.opacity(opacity * 0.15))
        )
        // Mid halo (1.8× size)
        let h = size * 1.8
        ctx.fill(
            Path(ellipseIn: CGRect(x: point.x - h / 2, y: point.y - h / 2, width: h, height: h)),
            with: .color(color.opacity(opacity * 0.35))
        )
        // Bright white core (0.5× size)
        let c = size * 0.5
        ctx.fill(
            Path(ellipseIn: CGRect(x: point.x - c / 2, y: point.y - c / 2, width: c, height: c)),
            with: .color(.white.opacity(opacity * 0.85))
        )
    }
}
