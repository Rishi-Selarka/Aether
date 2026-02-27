import SwiftUI
import UIKit
import ImageIO

/// Plays an animated GIF from the asset catalog using UIKit's UIImageView.
/// Uses NSDataAsset (Data Set in xcassets) so Swift Playgrounds bundles it correctly.
/// Falls back to a placeholder background color if the GIF cannot be loaded.
struct GIFImage: UIViewRepresentable {
    /// The name of the Data Set in Assets.xcassets (e.g. "daretodive_gif").
    let assetName: String

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.clipsToBounds = true

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.secondarySystemBackground
        imageView.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        // Prevent intrinsic image size from expanding the SwiftUI frame
        imageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        loadGIF(into: imageView)
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    // MARK: - GIF Loading

    private func loadGIF(into imageView: UIImageView) {
        guard let asset = NSDataAsset(name: assetName) else { return }
        let data = asset.data
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return }

        let frameCount = CGImageSourceGetCount(source)
        guard frameCount > 0 else { return }

        var frames: [UIImage] = []
        var totalDuration: Double = 0

        for index in 0 ..< frameCount {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) else {
                continue
            }
            frames.append(UIImage(cgImage: cgImage))
            totalDuration += frameDuration(at: index, source: source)
        }

        guard !frames.isEmpty else { return }

        imageView.animationImages = frames
        imageView.animationDuration = max(totalDuration, 0.1)
        imageView.animationRepeatCount = 0
        imageView.startAnimating()
        imageView.image = frames.first
    }

    private func frameDuration(at index: Int, source: CGImageSource) -> Double {
        let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [String: Any]
        let gifProperties = properties?[kCGImagePropertyGIFDictionary as String] as? [String: Any]

        let unclampedDelay = gifProperties?[
            kCGImagePropertyGIFUnclampedDelayTime as String
        ] as? Double
        let clampedDelay = gifProperties?[
            kCGImagePropertyGIFDelayTime as String
        ] as? Double

        let delay = unclampedDelay ?? clampedDelay ?? 0.1
        // GIF spec: delays < 0.02s should be treated as 0.1s
        return delay < 0.02 ? 0.1 : delay
    }
}
