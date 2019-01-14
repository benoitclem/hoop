//
//  ImageManipulator.swift
//  hoop
//
//  Created by Clément on 14/01/2019.
//  Copyright © 2019 hoop. All rights reserved.
//

import Foundation
import UIKit

class ImageManipulator {
    
    static var blurFactor = 2 // Blur factor at 50px
    
    static func imageWithImage(_ image: UIImage, withScale scale: CGFloat) -> UIImage? {
        let newWidth = image.size.width * scale
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0.0, y: 0.0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    static func desaturateImageWithImage(_ image: UIImage) -> UIImage? {
        let context = CIContext(options: nil)
        let currentFilter = CIFilter(name: "CIPhotoEffectNoir")
        currentFilter!.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        let output = currentFilter!.outputImage
        let cgimg = context.createCGImage(output!,from: output!.extent)
        return UIImage(cgImage: cgimg!)
    }
    
    static func blurImageWithImage(_ image: UIImage, andRadius radius: Int) -> UIImage? {
        let context = CIContext(options: nil)
        let currentFilter = CIFilter(name: "CIGaussianBlur")
        currentFilter?.setValue(radius, forKey: kCIInputRadiusKey)
        currentFilter!.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        let output = currentFilter!.outputImage
        let ciimage = CIImage(image: image)!
        let cgimg = context.createCGImage(output!,from: ciimage.extent)
        return UIImage(cgImage: cgimg!)
    }
    
    static func smallImage(_ image: UIImage, destSize: Float = 50.0 ) -> UIImage? {
        let scalefactor = CGFloat(destSize)/image.size.width
        return self.imageWithImage(image, withScale: scalefactor)
        
    }
    
    static func smallBluredAndDesaturatedImage(_ image: UIImage) -> UIImage? {
        let scalefactor = CGFloat(50.0)/image.size.width
        let desatImg = self.desaturateImageWithImage(image)
        let smallImg = self.imageWithImage(desatImg!, withScale: scalefactor)
        return self.blurImageWithImage(smallImg!, andRadius: ImageManipulator.blurFactor)
    }
    
    static func bluredAndDesaturatedImage(_ image: UIImage) -> UIImage? {
        let desatImg = self.desaturateImageWithImage(image)
        // Scale the blur factor to respect the 2px @ 50px img size
        let scaledBlurFactor = Int(desatImg!.size.width * CGFloat(ImageManipulator.blurFactor) / CGFloat(50.0))
        return self.blurImageWithImage(desatImg!, andRadius: scaledBlurFactor)
    }
}
