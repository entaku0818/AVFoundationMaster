//
//  CIImage+Utils.swift
//  
//  
//  Created by Naoya Maeda on 2024/05/25
//  
//

import CoreImage

extension CIImage {
    func toCGImage() -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(self, from: self.extent) {
            return cgImage
        }
        return nil
    }
}
