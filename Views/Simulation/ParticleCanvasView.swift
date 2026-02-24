import SwiftUI

struct ParticleCanvasView: View {
    let particles: [Particle]
    let nodes: [String: GraphNode]
    let operationColor: Color

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Canvas { context, size in
            for particle in particles {
                drawParticle(particle, in: context)
            }
        }
        .allowsHitTesting(false)
    }

    private func drawParticle(_ particle: Particle, in context: GraphicsContext) {
        guard let source = nodes[particle.sourceNodeID],
              let target = nodes[particle.targetNodeID] else { return }

        let from = CGPoint(x: source.x, y: source.y)
        let to = CGPoint(x: target.x, y: target.y)
        let pos = interpolateBezier(from: from, to: to, progress: particle.progress)

        let radius: CGFloat = 6
        let rect = CGRect(x: pos.x - radius, y: pos.y - radius, width: radius * 2, height: radius * 2)
        context.fill(Path(ellipseIn: rect), with: .color(operationColor.opacity(particle.opacity)))

        if !reduceMotion && particle.progress < 1 {
            let trailPos = interpolateBezier(from: from, to: to, progress: max(0, particle.progress - 0.15))
            let trailRect = CGRect(x: trailPos.x - 2, y: trailPos.y - 2, width: 4, height: 4)
            context.fill(Path(ellipseIn: trailRect), with: .color(operationColor.opacity(0.4)))
        }
    }

    private func interpolateBezier(from: CGPoint, to: CGPoint, progress: CGFloat) -> CGPoint {
        let midX = (from.x + to.x) / 2
        let midY = (from.y + to.y) / 2
        let c1 = CGPoint(x: midX + (to.y - from.y) * 0.3, y: midY - (to.x - from.x) * 0.3)
        let c2 = CGPoint(x: midX - (to.y - from.y) * 0.3, y: midY + (to.x - from.x) * 0.3)
        let t = progress
        let mt = 1 - t
        let x = mt*mt*mt*from.x + 3*mt*mt*t*c1.x + 3*mt*t*t*c2.x + t*t*t*to.x
        let y = mt*mt*mt*from.y + 3*mt*mt*t*c1.y + 3*mt*t*t*c2.y + t*t*t*to.y
        return CGPoint(x: x, y: y)
    }
}
