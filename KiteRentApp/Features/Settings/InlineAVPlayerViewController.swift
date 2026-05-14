import AVKit
import SwiftUI

/// Uses `AVPlayerViewController` instead of SwiftUI `VideoPlayer` for smoother high‑resolution
/// local playback (less compositor overhead than `VideoPlayer` in scrolling containers).
struct InlineAVPlayerViewController: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        controller.videoGravity = .resizeAspect
        if #available(iOS 17.0, *) {
            controller.allowsVideoFrameAnalysis = false
        }
        return controller
    }

    func updateUIViewController(_ controller: AVPlayerViewController, context: Context) {
        if controller.player !== player {
            controller.player = player
        }
    }
}
