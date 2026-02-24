import SwiftUI

struct CanvasView<Content: View>: View {
    let canvasSize: CGSize
    @ViewBuilder let content: () -> Content
    
    init(canvasSize: CGSize = CGSize(width: 2000, height: 2000), @ViewBuilder content: @escaping () -> Content) {
        self.canvasSize = canvasSize
        self.content = content
    }
    
    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: false) {
            ZStack(alignment: .topLeading) {
                GridView(size: canvasSize)
                content()
            }
            .frame(width: canvasSize.width, height: canvasSize.height)
        }
        .background(Color.archsysBackground)
    }
}

struct GridView: View {
    let size: CGSize
    private let gridSize = LayoutConstants.gridSize
    
    var body: some View {
        Canvas { context, _ in
            let spacing = gridSize
            var x: CGFloat = 0
            while x <= size.width {
                var y: CGFloat = 0
                while y <= size.height {
                    let rect = CGRect(x: x - 1, y: y - 1, width: 2, height: 2)
                    context.fill(Path(ellipseIn: rect), with: .color(Color.archsysBorder.opacity(0.5)))
                    y += spacing
                }
                x += spacing
            }
        }
        .frame(width: size.width, height: size.height)
    }
}
