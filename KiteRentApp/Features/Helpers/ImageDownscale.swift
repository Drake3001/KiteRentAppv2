//
//  ImageDownscale.swift
//  KiteRentApp
//

import UIKit

enum ImageDownscale {
    /// Returns JPEG data, optionally resized so the longest edge is at most `maxLongEdge` points.
    static func jpegDataResized(_ data: Data, maxLongEdge: CGFloat = 2048, quality: CGFloat = 0.85) -> Data? {
        guard let image = UIImage(data: data) else { return data }
        let size = image.size
        let maxDim = max(size.width, size.height)
        guard maxDim > maxLongEdge else {
            return image.jpegData(compressionQuality: quality)
        }
        let scale = maxLongEdge / maxDim
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resized?.jpegData(compressionQuality: quality) ?? data
    }
}
