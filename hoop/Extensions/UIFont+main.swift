//
//  UIFont+main.swift
//  hoop
//
//  Created by Clément on 20/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit

extension UIFont {
    private static func customFont(name: String, size: CGFloat) -> UIFont {
        let font = UIFont(name: name, size: size)
        assert(font != nil, "Can't load font: \(name)")
        return font ?? UIFont.systemFont(ofSize: size)
    }
    
    static func MainFontLight(ofSize size: CGFloat) -> UIFont {
        return customFont(name: "Campton-Light", size: size)
    }
    
    static func MainFontMedium(ofSize size: CGFloat) -> UIFont {
        return customFont(name: "Campton-Medium", size: size)
    }
}

