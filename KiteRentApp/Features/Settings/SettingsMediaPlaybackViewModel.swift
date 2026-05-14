import AVFoundation
import Combine
import Foundation
import UIKit

/// Loads tutorial **video** from a bundle file URL when possible (best for 4K), otherwise from an asset
/// catalog **Data set**. Loads **audio** from the `SettingsTutorialAudio` data set.
@MainActor
final class SettingsMediaPlaybackViewModel: NSObject, ObservableObject {
    static let videoAssetName = "SettingsTutorialVideo"
    static let audioAssetName = "SettingsTutorialAudio"

    @Published private(set) var videoPlayer: AVPlayer?
    @Published private(set) var videoUnavailableReason: String?
    @Published private(set) var audioUnavailableReason: String?
    @Published private(set) var isAudioPlaying = false

    private var audioPlayer: AVAudioPlayer?
    /// Set when video was materialized from an `NSDataAsset` (deleted on teardown). Nil when using a bundle file URL.
    private var tempVideoFileURL: URL?

    override init() {
        super.init()
    }

    func onAppear() {
        loadVideoFromAsset()
        validateAudioAsset()
    }

    func teardown() {
        videoPlayer?.pause()
        videoPlayer?.replaceCurrentItem(with: nil)
        videoPlayer = nil

        audioPlayer?.stop()
        audioPlayer = nil
        isAudioPlaying = false

        if let url = tempVideoFileURL {
            try? FileManager.default.removeItem(at: url)
            tempVideoFileURL = nil
        }
    }

    func toggleAudioPlayback() {
        if audioPlayer == nil, audioUnavailableReason != nil {
            return
        }

        if audioPlayer == nil {
            guard let asset = NSDataAsset(name: Self.audioAssetName), !asset.data.isEmpty else {
                audioUnavailableReason =
                    "Audio data is empty. Add a file to the SettingsTutorialAudio data set in Assets."
                return
            }
            do {
                let player = try AVAudioPlayer(data: asset.data)
                player.delegate = self
                audioPlayer = player
                audioUnavailableReason = nil
            } catch {
                audioUnavailableReason = error.localizedDescription
                return
            }
        }

        guard let player = audioPlayer else { return }

        if isAudioPlaying {
            player.stop()
            player.currentTime = 0
            isAudioPlaying = false
        } else {
            player.play()
            isAudioPlaying = true
        }
    }

    /// Prefer a **bundle resource** (`SettingsTutorialVideo.mp4` / `.mov` / `.m4v`) so playback reads from disk
    /// without loading the whole file into memory (important for 4K). Falls back to the asset catalog **Data set**.
    private func bundledVideoURL() -> URL? {
        let name = Self.videoAssetName
        for ext in ["mp4", "mov", "m4v"] {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                return url
            }
        }
        return nil
    }

    private func makePlayer(forFileURL url: URL) -> AVPlayer {
        let urlAsset = AVURLAsset(
            url: url,
            options: [AVURLAssetPreferPreciseDurationAndTimingKey: false]
        )
        let item = AVPlayerItem(asset: urlAsset)
        // A few seconds of forward buffer helps avoid stalls on high‑bitrate 4K from storage.
        item.preferredForwardBufferDuration = 5
        let player = AVPlayer(playerItem: item)
        // Local file: avoid extra “wait to minimize stalling” delay before first frames.
        player.automaticallyWaitsToMinimizeStalling = false
        return player
    }

    private func loadVideoFromAsset() {
        videoUnavailableReason = nil
        videoPlayer = nil
        if let old = tempVideoFileURL {
            try? FileManager.default.removeItem(at: old)
            tempVideoFileURL = nil
        }

        if let bundleURL = bundledVideoURL() {
            videoPlayer = makePlayer(forFileURL: bundleURL)
            return
        }

        guard let asset = NSDataAsset(name: Self.videoAssetName) else {
            videoUnavailableReason =
                "Video is not configured. Add \(Self.videoAssetName).mp4 to the app target, or a Data set named \(Self.videoAssetName) in Assets."
            return
        }
        guard !asset.data.isEmpty else {
            videoUnavailableReason =
                "Video data is empty. Add a file to the \(Self.videoAssetName) data set in Assets."
            return
        }

        let temp = FileManager.default.temporaryDirectory
            .appendingPathComponent("SettingsTutorialVideo-\(UUID().uuidString).mp4", isDirectory: false)
        do {
            let payload = asset.data
            try payload.write(to: temp, options: .atomic)
            tempVideoFileURL = temp
            videoPlayer = makePlayer(forFileURL: temp)
        } catch {
            videoUnavailableReason = error.localizedDescription
            try? FileManager.default.removeItem(at: temp)
            tempVideoFileURL = nil
        }
    }

    private func validateAudioAsset() {
        audioUnavailableReason = nil
        guard let asset = NSDataAsset(name: Self.audioAssetName) else {
            audioUnavailableReason =
                "Audio is not configured. Add a Data set named \(Self.audioAssetName) in Assets."
            return
        }
        guard !asset.data.isEmpty else {
            audioUnavailableReason =
                "Audio data is empty. Add a file to the \(Self.audioAssetName) data set in Assets."
            return
        }
    }
}

extension SettingsMediaPlaybackViewModel: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor [weak self] in
            self?.isAudioPlaying = false
        }
    }
}
