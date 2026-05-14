import SwiftUI

struct SettingsMediaPlaybackView: View {
    @StateObject private var viewModel = SettingsMediaPlaybackViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                videoChrome
                    .frame(minHeight: 220)

                Form {
                    Section("Audio") {
                        if let reason = viewModel.audioUnavailableReason {
                            Text(reason)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            Button(viewModel.isAudioPlaying ? "Stop" : "Play") {
                                viewModel.toggleAudioPlayback()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Tutorials")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.blue)
                }
            }
            .onAppear {
                viewModel.onAppear()
            }
            .onDisappear {
                viewModel.teardown()
            }
        }
    }

    @ViewBuilder
    private var videoChrome: some View {
        if let player = viewModel.videoPlayer {
            InlineAVPlayerViewController(player: player)
        } else if let reason = viewModel.videoUnavailableReason {
            Text(reason)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        } else {
            Color.clear
        }
    }
}

#Preview {
    SettingsMediaPlaybackView()
}
