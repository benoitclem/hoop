//
//  UIGradientView.swift
//  uxTests
//
//  Created by Clément on 12/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit

@IBDesignable class UIGradientView: UIView {
    @IBInspectable var firstColor: UIColor = UIColor.white
    @IBInspectable var secondColor: UIColor = UIColor.black
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        (layer as! CAGradientLayer).colors = [firstColor.cgColor, secondColor.cgColor]
        (layer as! CAGradientLayer).startPoint = CGPoint(x: 0, y: 0.75)
        (layer as! CAGradientLayer).endPoint = CGPoint (x: 1, y: 0.25)
    }
}
