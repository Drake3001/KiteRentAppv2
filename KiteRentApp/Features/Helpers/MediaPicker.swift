//
//  MediaPicker.swift
//  KiteRentApp
//

import SwiftUI
import PhotosUI

struct MediaPicker: View {
    @Binding var selection: PhotosPickerItem?
    var label: String
    var onPicked: (MediaProcessor.Result) -> Void
    var downscale: Bool = true

    var body: some View {
        PhotosPicker(selection: $selection, matching: .images, photoLibrary: .shared()) {
            Text(label)
        }
        .onChange(of: selection) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    let maxLongEdge: CGFloat = downscale ? 2048 : 8192
                    if let result = try? await MediaProcessor.process(data, maxLongEdge: maxLongEdge) {
                        await MainActor.run { onPicked(result) }
                    }
                }
                await MainActor.run { selection = nil }
            }
        }
    }
}

/// Loads the original photo bytes without resizing or compression. Use for kite flows that run their own pipeline.
struct RawPhotoPicker: View {
    @Binding var selection: PhotosPickerItem?
    var label: String
    var onPicked: (Data) -> Void

    var body: some View {
        PhotosPicker(selection: $selection, matching: .images, photoLibrary: .shared()) {
            Text(label)
        }
        .onChange(of: selection) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    await MainActor.run { onPicked(data) }
                }
                await MainActor.run { selection = nil }
            }
        }
    }
}
