//
//  UILabel+stylizable.swift
//  hoop
//
//  Created by Clément on 20/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit

extension UILabel {
    
    func stylizeSubstring(_ substr: String,_ fgColor: UIColor,_ underlineStyle: NSUnderlineStyle?) {
        guard substr.isEmpty == false,
            let text = attributedText,
            let range = text.string.range(of: substr, options: .caseInsensitive) else {
                return
        }
        let attr = NSMutableAttributedString(attributedString: text)
        let start = text.string.distance(from: text.string.startIndex, to: range.lowerBound)
        let length = text.string.distance(from: range.lowerBound, to: range.upperBound)
        let underlinedBoldedAttributes: [NSAttributedString.Key: Any] = [
            .font : UIFont.MainFontMedium(ofSize: 12.0),
            .foregroundColor : fgColor,
            .underlineStyle : underlineStyle != nil ? underlineStyle!.rawValue : 0
        ]
        attr.addAttributes(underlinedBoldedAttributes, range: NSMakeRange(start, length))
        attributedText = attr
    }
}
