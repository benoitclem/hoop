//
//  HoopDateCell.swift
//  hoop
//
//  Created by Clément on 03/01/2019.
//  Copyright © 2019 hoop. All rights reserved.
//

import Eureka
import UIKit

public class HoopDateCell: Cell<Date>, CellType {
    
    @IBOutlet weak var rowLabel: UILabel!
    @IBOutlet weak var rowDateLabel: UILabel!
    public var datePicker = UIDatePicker()
    
    public override func setup() {
        super.setup()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(HoopDateCell.datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    deinit {
        datePicker.removeTarget(self, action: nil, for: .allEvents)
    }
    
    public override func update() {
        super.update()
        if let labelText = (row as? HoopDateRow)?.labelText {
            rowLabel.text = labelText
        }
        rowDateLabel?.text = row.displayValueFor?(row.value)
        selectionStyle = row.isDisabled ? .none : .default
        datePicker.setDate(row.value ?? Date(), animated: row is CountDownPickerRow)
        datePicker.minimumDate = (row as? DatePickerRowProtocol)?.minimumDate
        datePicker.maximumDate = (row as? DatePickerRowProtocol)?.maximumDate
        if let minuteIntervalValue = (row as? DatePickerRowProtocol)?.minuteInterval {
            datePicker.minuteInterval = minuteIntervalValue
        }
    }
    
    open override func didSelect() {
        super.didSelect()
        row.deselect()
    }
    
    override open var inputView: UIView? {
        if let v = row.value {
            datePicker.setDate(v, animated:row is CountDownRow)
        }
        return datePicker
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        row.value = sender.date
        rowDateLabel?.text = row.displayValueFor?(row.value)
    }
    
    open override func cellCanBecomeFirstResponder() -> Bool {
        return canBecomeFirstResponder
    }
    
    override open var canBecomeFirstResponder: Bool {
        return !row.isDisabled
    }
    
}

public final class HoopDateRow: Row<HoopDateCell>, DatePickerRowProtocol, RowType {
    
    /// The minimum value for this row's UIDatePicker
    public var minimumDate: Date?
    
    /// The maximum value for this row's UIDatePicker
    public var maximumDate: Date?
    
    /// The interval between options for this row's UIDatePicker
    public var minuteInterval: Int?
    
    public var labelText: String?
    
    var dateFormatter: DateFormatter?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<HoopDateCell>(nibName: "HoopDateCell")
        displayValueFor = { [unowned self] value in
            guard let val = value, let formatter = self.dateFormatter else { return nil }
            return formatter.string(from: val)
        }
    }
}
