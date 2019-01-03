//
//  HoopListCheckCell.swift
//  hoop
//
//  Created by Clément on 03/01/2019.
//  Copyright © 2019 hoop. All rights reserved.
//

import Foundation
import UIKit
import Eureka

open class HoopListCheckCell : Cell<Bool>, CellType {
    
    @IBOutlet weak var labelText: UILabel!
    
    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func update() {
        super.update()
        accessoryType = row.value != nil ? .checkmark : .none
        editingAccessoryType = accessoryType
        selectionStyle = .default
        if row.isDisabled {
            tintAdjustmentMode = .dimmed
            selectionStyle = .none
        } else {
            tintAdjustmentMode = .automatic
        }
    }
    
    open override func setup() {
        super.setup()
        labelText?.text = (row as? HoopListCheckRow)?.labelText
        accessoryType =  .checkmark
        editingAccessoryType = accessoryType
    }
    
    open override func didSelect() {
        row.deselect()
        row.updateCell()
    }
    
}

public final class HoopListCheckRow: Row<HoopListCheckCell>, SelectableRowType, RowType {
    public var labelText: String?
    public var selectableValue: Bool?
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<HoopListCheckCell>(nibName: "HoopListCheckCell")
        displayValueFor = nil
    }
}
