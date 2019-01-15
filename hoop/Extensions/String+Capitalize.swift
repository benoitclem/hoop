//
//  String+Capitalize.swift
//  hoop
//
//  Created by Clément on 15/01/2019.
//  Copyright © 2019 hoop. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func capitalizingFirstLetter() -> String {
        let first = self.prefix(1).capitalized
        let other = self.dropFirst()
        return first + other
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
