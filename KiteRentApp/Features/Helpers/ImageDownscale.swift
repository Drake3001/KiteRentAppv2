//
//  ImageDownscale.swift
//  KiteRentApp
//

import UIKit

enum ImageDownscale {
    static func pngDataResized(_ data: Data, maxLongEdge: CGFloat = 2048) -> Data? {
        guard let image = UIImage(data: data) else { return data }
        let size = image.size
        let maxDim = max(size.width, size.height)

        guard maxDim > maxLongEdge else {
            return image.pngData()
        }

        let scale = maxLongEdge / maxDim
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resized?.pngData() ?? image.pngData() ?? data
    }
}
