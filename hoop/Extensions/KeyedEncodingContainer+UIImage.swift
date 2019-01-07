//
//  KeyedEncodingContainer+UIImage.swift
//  hoop
//
//  Created by Clément on 07/01/2019.
//  Copyright © 2019 hoop. All rights reserved.
//

import Foundation
import UIKit

enum ImageEncodingQuality: CGFloat {
    case png = 0
    case jpegLow = 0.2
    case jpegMid = 0.5
    case jpegHigh = 0.75
}

extension KeyedEncodingContainer {
    
    mutating func encode(_ value: UIImage,
                         forKey key: KeyedEncodingContainer.Key,
                         quality: ImageEncodingQuality = .png) throws {
        var imageData: Data!
        if quality == .png {
            imageData = value.pngData()
        } else {
            imageData = value.jpegData(compressionQuality: quality.rawValue)
        }
        try encode(imageData, forKey: key)
    }
    
    
    mutating func encode(_ values: [UIImage],
                         forKey key: KeyedEncodingContainer.Key,
                         quality: ImageEncodingQuality = .png) throws {
        for value in values {
            var imagesData = [Data]()
            if quality == .png {
                if let data = value.pngData() {
                    imagesData.append(data)
                }
            } else {
                if let data = value.jpegData(compressionQuality: quality.rawValue) {
                    imagesData.append(data)
                }
            }
            try encode(imagesData, forKey: key)
        }
    }

    
}

extension KeyedDecodingContainer {
    
    
    public func decode(_ type: UIImage.Type, forKey key: KeyedDecodingContainer.Key) throws -> UIImage {
        let imageData = try decode(Data.self, forKey: key)
        if let image = UIImage(data: imageData) {
            return image
        } else {
            throw NSError(domain: "HoopUIImageDecodingError", code: -1, userInfo: ["desc":"could not decode UIImage"])
        }
    }
    
    public func decode(_ type: [UIImage].Type, forKey key: KeyedDecodingContainer.Key) throws -> [UIImage] {
        var images = [UIImage]()
        let imagesData = try decode([Data].self, forKey: key)
        for imageData in imagesData {
            if let image = UIImage(data: imageData) {
                images.append(image)
            } else {
                throw NSError(domain: "HoopUIImageDecodingError", code: -2, userInfo: ["desc":"could not decode [UIImage]"])
            }
        }
        return images
    }

    
}
