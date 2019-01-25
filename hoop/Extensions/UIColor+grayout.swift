//
//  UIColor+grayout.swift
//  hoop
//
//  Created by Clément on 25/01/2019.
//  Copyright © 2019 hoop. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    func grayout(byPoints points: CGFloat? = 0.5) -> UIColor {
        var h: CGFloat = 0.0
        var s: CGFloat = 0.0
        var v: CGFloat = 0.0
        var a: CGFloat = 0.0
        self.getHue(&h, saturation: &s, brightness: &v, alpha: &a)
        
        return UIColor.init(hue: h, saturation: s-points!, brightness: v, alpha: a)
    }
}
