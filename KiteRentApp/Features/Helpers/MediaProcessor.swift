//
//  MediaProcessor.swift
//  KiteRentApp
//

import UIKit

enum MediaProcessor {
    struct Result: Sendable {
        let data: Data
        let thumbnailData: Data
        let mimeType: String
        let pixelWidth: Int
        let pixelHeight: Int
    }

    /// Resizes, compresses to JPEG when possible, and builds a JPEG thumbnail.
    /// Use `preserveAlpha: true` when the pipeline needs transparency (e.g. future background removal).
    static func process(
        _ input: Data,
        maxLongEdge: CGFloat = 2048,
        thumbnailLongEdge: CGFloat = 200,
        jpegQuality: CGFloat = 0.75,
        preserveAlpha: Bool = false
    ) async throws -> Result {
        try await Task.detached(priority: .userInitiated) {
            guard let image = UIImage(data: input) else {
                throw MediaProcessingError.decodeFailed
            }

            let mainImage = Self.resizedImage(image, maxLongEdge: maxLongEdge)
            let thumbSource = Self.resizedImage(mainImage, maxLongEdge: thumbnailLongEdge)

            let mainData: Data
            let mimeType: String

            if preserveAlpha {
                guard let png = mainImage.pngData() else {
                    throw MediaProcessingError.encodeFailed
                }
                mainData = png
                mimeType = "image/png"
            } else {
                let toEncode = Self.hasAlphaChannel(mainImage)
                    ? Self.flattenedForJPEG(mainImage)
                    : mainImage
                guard let jpeg = toEncode.jpegData(compressionQuality: jpegQuality) else {
                    throw MediaProcessingError.encodeFailed
                }
                mainData = jpeg
                mimeType = "image/jpeg"
            }

            let thumbnailData: Data
            if preserveAlpha {
                guard let png = thumbSource.pngData() else {
                    throw MediaProcessingError.encodeFailed
                }
                thumbnailData = png
            } else {
                let flatThumb = Self.flattenedForJPEG(thumbSource)
                guard let jpeg = flatThumb.jpegData(compressionQuality: 0.72) else {
                    throw MediaProcessingError.encodeFailed
                }
                thumbnailData = jpeg
            }

            let w = Int(mainImage.size.width * mainImage.scale)
            let h = Int(mainImage.size.height * mainImage.scale)

            return Result(
                data: mainData,
                thumbnailData: thumbnailData,
                mimeType: mimeType,
                pixelWidth: w,
                pixelHeight: h
            )
        }.value
    }

    private static func resizedImage(_ image: UIImage, maxLongEdge: CGFloat) -> UIImage {
        let size = image.size
        let maxDim = max(size.width, size.height)
        guard maxDim > maxLongEdge else { return image }

        let scale = maxLongEdge / maxDim
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    private static func hasAlphaChannel(_ image: UIImage) -> Bool {
        guard let cg = image.cgImage else { return false }
        switch cg.alphaInfo {
        case .first, .last, .premultipliedFirst, .premultipliedLast, .alphaOnly:
            return true
        default:
            return false
        }
    }

    /// Draws onto an opaque white background so JPEG encoding is well-defined.
    private static func flattenedForJPEG(_ image: UIImage) -> UIImage {
        guard hasAlphaChannel(image) else { return image }
        let size = image.size
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

enum MediaProcessingError: Error {
    case decodeFailed
    case encodeFailed
}
