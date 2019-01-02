//
//  Date+age.swift
//  hoop
//
//  Created by Clément on 02/01/2019.
//  Copyright © 2019 hoop. All rights reserved.
//

import Foundation

extension Date {
    func age() -> Int {
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let now: Date! = Date()
        let calcAge = calendar.components(.year, from: self, to: now, options: [])
        return calcAge.year!
    }
}
