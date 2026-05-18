//
//  BackgroundRemover.swift
//  KiteRentApp
//

import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit
import Vision

enum BackgroundRemovalError: Error {
    case decodeFailed
    case visionFailed
    case noMask
    case composeFailed
    case encodeFailed
}

enum BackgroundRemover {
    static func removeBackground(from imageData: Data) async throws -> Data {
        try await Task.detached(priority: .userInitiated) {
            guard let uiImage = UIImage(data: imageData), let ciImage = CIImage(image: uiImage) else {
                throw BackgroundRemovalError.decodeFailed
            }

            let request = VNGenerateForegroundInstanceMaskRequest()
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                throw BackgroundRemovalError.visionFailed
            }

            guard let observation = request.results?.first as? VNInstanceMaskObservation else {
                throw BackgroundRemovalError.noMask
            }

            let instances = observation.allInstances
            guard !instances.isEmpty else {
                throw BackgroundRemovalError.noMask
            }

            let maskBuffer: CVPixelBuffer
            do {
                maskBuffer = try observation.generateScaledMaskForImage(forInstances: instances, from: handler)
            } catch {
                throw BackgroundRemovalError.noMask
            }

            let maskImage = CIImage(cvPixelBuffer: maskBuffer)

            let filter = CIFilter.blendWithMask()
            filter.inputImage = ciImage
            filter.maskImage = maskImage
            filter.backgroundImage = CIImage(color: CIColor(red: 0, green: 0, blue: 0, alpha: 0))
                .cropped(to: ciImage.extent)

            guard let output = filter.outputImage else {
                throw BackgroundRemovalError.composeFailed
            }

            let context = CIContext(options: [.useSoftwareRenderer: false])
            guard let cgImage = context.createCGImage(output, from: output.extent) else {
                throw BackgroundRemovalError.composeFailed
            }

            let outUIImage = UIImage(cgImage: cgImage, scale: uiImage.scale, orientation: uiImage.imageOrientation)
            guard let png = outUIImage.pngData() else {
                throw BackgroundRemovalError.encodeFailed
            }
            return png
        }.value
    }
}
