//
//  UIColor+colors.swift
//  hoop
//
//  Created by Clément on 19/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit

let HoopRedColor = UIColor.init(red: 0xb3/255, green: 0x1e/255, blue: 0x12/255, alpha: 1.0)
let HoopGreenColor = UIColor.init(red: 18/255, green: 179/255, blue: 87/255, alpha: 1.0)

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    static let hoopRedColor = UIColor(netHex:0xb31e12)
    static let hoopGreenColor = UIColor(netHex:0x12b357)
}
