//
//  File.swift
//  
//
//  Created by Jorge Mattei on 8/4/23.
//

import Foundation
import CoreGraphics

extension CGImage {
    func resize(to size:CGSize) -> CGImage? {
        let image = self
        var ratio: Double = 0.0
        let imageWidth = Double(image.width)
        let imageHeight = Double(image.height)
        let maxWidth: Double = Double(size.width)
        let maxHeight: Double = Double(size.height)

        // Get ratio (landscape or portrait)
        if (imageWidth > imageHeight) {
            ratio = maxWidth / imageWidth
        } else {
            ratio = maxHeight / imageHeight
        }

        // Calculate new size based on the ratio
        if ratio > 1 {
            ratio = 1
        }

        let width = imageWidth * ratio
        let height = imageHeight * ratio

        guard let colorSpace = image.colorSpace else { return nil }
        guard let context = CGContext(data: nil, width: Int(ceil(width)), height: Int(ceil(height)), bitsPerComponent: image.bitsPerComponent, bytesPerRow: image.bytesPerRow, space: colorSpace, bitmapInfo: image.alphaInfo.rawValue) else { return nil }

        // draw image to context (resizing it)
        context.interpolationQuality = .high
        context.draw(image, in: CGRect(x: 0, y: 0, width: Int(width), height: Int(height)))

        // extract resulting image from context
        return context.makeImage()
    }
}

