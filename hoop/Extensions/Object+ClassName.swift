//
//  Object+ClassName.swift
//  popupTests
//
//  Created by Clément on 14/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import Foundation

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}
