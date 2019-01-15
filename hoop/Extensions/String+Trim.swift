//
//  String+Trim.swift
//  hoop
//
//  Created by Clément on 15/01/2019.
//  Copyright © 2019 hoop. All rights reserved.
//

import Foundation

extension String {
    func triming() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    mutating func trim() {
        self = self.triming()
    }
}
