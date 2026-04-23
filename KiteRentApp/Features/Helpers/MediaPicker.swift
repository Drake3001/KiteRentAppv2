//
//  MediaPicker.swift
//  KiteRentApp
//

import SwiftUI
import PhotosUI

struct MediaPicker: View {
    @Binding var selection: PhotosPickerItem?
    var label: String
    var onPicked: (Data) -> Void
    var downscale: Bool = true

    var body: some View {
        PhotosPicker(selection: $selection, matching: .images, photoLibrary: .shared()) {
            Text(label)
        }
        .onChange(of: selection) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    if downscale, let jpg = ImageDownscale.jpegDataResized(data) {
                        onPicked(jpg)
                    } else {
                        onPicked(data)
                    }
                }
                await MainActor.run { selection = nil }
            }
        }
    }
}
