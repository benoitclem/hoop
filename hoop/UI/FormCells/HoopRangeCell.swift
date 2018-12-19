//
//  HoopRangeCell.swift
//  formTests
//
//  Created by Clément on 17/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit
import Eureka

public struct Range: Equatable {
    var min: Double
    var low: Double
    var upp: Double
    var max: Double
    
    var description: String {
        return "Range [\(min) \(low) \(upp) \(max)]"
    }
}

public func ==(lhs: Range, rhs: Range) -> Bool {
    return lhs.min == rhs.min && lhs.low == rhs.low && lhs.upp == rhs.upp && lhs.max == rhs.max
}

public class HoopRangeCell: Cell<Range>, CellType {
    
    @IBOutlet weak var rowTitle: UILabel!
    @IBOutlet weak var rowValue: UILabel!
    @IBOutlet weak var rowSlider: RangeSlider!
    
    public override func setup() {
        super.setup()
        rowSlider.maximumValue = 1000.0 // Workaround for Range init
        rowSlider.addTarget(self, action: #selector(HoopRangeCell.rangeSliderValueChanged(_:)),
                              for: .valueChanged)
    }
    
    public override func update() {
        super.update()
        // Do some custom here
        rowTitle.text = (row as! HoopRangeRow).labelText
        if let range = (row as! HoopRangeRow).value {
            rowSlider.minimumValue = range.min
            rowSlider.lowerValue = range.low
            rowSlider.upperValue = range.upp
            rowSlider.maximumValue = range.max
            rowValue.text = makeValueString(from: range)
        }
    }
    
    @objc func rangeSliderValueChanged(_  control: RangeSlider) {
        (row as! HoopRangeRow).value = Range(min: control.minimumValue, low: control.lowerValue, upp: control.upperValue, max: control.maximumValue)
        update()
    }
    
    func makeValueString(from range:Range?) -> String {
        if let range = range {
            var s = "\(Int(range.low)) - \(Int(range.upp))"
            if (range.upp == 55) {
                s += "+"
            }
            return s
        } else {
            return "not well binded"
        }
    }
}

public final class HoopRangeRow: Row<HoopRangeCell>, RowType {
    
    public var labelText: String?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<HoopRangeCell>(nibName: "HoopRangeCell")
    }
}
