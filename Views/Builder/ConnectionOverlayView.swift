import SwiftUI

struct ConnectionOverlayView: View {
    let graph: ArchitectureGraph
    
    private var nodesByID: [String: GraphNode] {
        Dictionary(uniqueKeysWithValues: graph.allNodes.map { ($0.id, $0) })
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(Array(graph.allConnections), id: \.id) { edge in
                connectionLine(for: edge)
            }
        }
        .allowsHitTesting(false)
    }
    
    @ViewBuilder
    private func connectionLine(for edge: GraphEdge) -> some View {
        if let source = graph.node(for: edge.sourceID),
           let target = graph.node(for: edge.targetID) {
            ConnectionLine(source: source, target: target)
        }
    }
}

struct ConnectionLine: View {
    let source: GraphNode
    let target: GraphNode
    
    var body: some View {
        ConnectionPath(
            from: CGPoint(x: source.x, y: source.y),
            to: CGPoint(x: target.x, y: target.y)
        )
            .stroke(Color.archsysTextSecondary.opacity(0.6), style: StrokeStyle(lineWidth: 2, lineCap: .round))
    }
}

struct ConnectionPath: Shape {
    let from: CGPoint
    let to: CGPoint
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: from)
        
        let midX = (from.x + to.x) / 2
        let midY = (from.y + to.y) / 2
        let control1 = CGPoint(x: midX + (to.y - from.y) * 0.2, y: midY - (to.x - from.x) * 0.2)
        let control2 = CGPoint(x: midX - (to.y - from.y) * 0.2, y: midY + (to.x - from.x) * 0.2)
        
        path.addCurve(to: to, control1: control1, control2: control2)
        return path
    }
}
