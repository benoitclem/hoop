//
//  HoopLabelCell.swift
//  formTests
//
//  Created by Clément on 17/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit
import Eureka

public class HoopLabelCell: Cell<String>, CellType {
    
    @IBOutlet weak var rowTitle: UILabel!
    @IBOutlet weak var rowValue: UILabel!
    @IBOutlet weak var rowIndicator: UIImageView!
    
    public override func setup() {
        super.setup()
        // switchControl.addTarget(self, action: #selector(CustomCell.switchValueChanged), for: .valueChanged)
    }
    
    public override func update() {
        super.update()
        // Do some custom here
        rowTitle.text = (row as! HoopLabelRow).labelText
        if let image = (row as! HoopLabelRow).indicator {
            rowValue.isHidden = false
            rowIndicator.image = image
        } else {
            rowValue.isHidden = true
        }
        if let v = (row as! HoopLabelRow).value {
            rowValue.isHidden = false
            rowValue.text = v
        } else {
            rowValue.isHidden = true
        }
        if let style = (row as! HoopLabelRow).labelStyle {
            rowTitle.textAlignment = style.txtAlignement ?? .left
            rowTitle.textColor = style.txtColor
            self.backgroundColor = style.bgColor
        }
        
    }
}

public struct HoopLabelRowStyle {
    var bgColor: UIColor?
    var txtColor: UIColor?
    var txtAlignement: NSTextAlignment?
}

public final class HoopLabelRow: Row<HoopLabelCell>, RowType {
    
    // Here don't use default title because it causes duplicate
    public var labelText: String?
    public var labelStyle: HoopLabelRowStyle?
    public var indicator: UIImage?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<HoopLabelCell>(nibName: "HoopLabelCell")
    }
}
