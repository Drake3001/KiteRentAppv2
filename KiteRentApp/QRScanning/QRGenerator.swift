//
//  QRGenerator.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 23/11/2025.
//

import UIKit
import CoreImage.CIFilterBuiltins

struct QRGenerator {
    static func generateQRCode(from string: String) -> UIImage? {
        let data = Data(string.utf8)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")

        let transform = CGAffineTransform(scaleX: 10, y: 10)

        guard let outputImage = filter.outputImage?.transformed(by: transform) else { return nil }

        let context = CIContext()
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        }

        return nil
    }
}

