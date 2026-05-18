import AVFoundation
import Combine
import Foundation
import UIKit

/// Loads tutorial **video** from a bundle file only (`SettingsTutorialVideo.mp4` / `.mov` / `.m4v`).
/// Loads **audio** from the `SettingsTutorialAudio` asset catalog data set.
@MainActor
final class SettingsMediaPlaybackViewModel: NSObject, ObservableObject {
    static let videoResourceName = "SettingsTutorialVideo"
    static let audioAssetName = "SettingsTutorialAudio"

    @Published private(set) var videoPlayer: AVPlayer?
    @Published private(set) var videoUnavailableReason: String?
    @Published private(set) var audioUnavailableReason: String?
    @Published private(set) var isAudioPlaying = false

    private var audioPlayer: AVAudioPlayer?

    override init() {
        super.init()
    }

    func onAppear() {
        loadBundledVideo()
        validateAudioAsset()
    }

    func teardown() {
        videoPlayer?.pause()
        videoPlayer?.replaceCurrentItem(with: nil)
        videoPlayer = nil

        audioPlayer?.stop()
        audioPlayer = nil
        isAudioPlaying = false
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

    private func bundledVideoURL() -> URL? {
        let name = Self.videoResourceName
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
        item.preferredForwardBufferDuration = 5
        
        let player = AVPlayer(playerItem: item)
        
        player.automaticallyWaitsToMinimizeStalling = false
        return player
    }

    private func loadBundledVideo() {
        videoUnavailableReason = nil
        videoPlayer = nil

        guard let bundleURL = bundledVideoURL() else {
            videoUnavailableReason =
                "Video is not configured. Add \(Self.videoResourceName).mp4 (or .mov / .m4v) to the app target."
            return
        }
        videoPlayer = makePlayer(forFileURL: bundleURL)
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
