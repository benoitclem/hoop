//
//  HoopTextViewCell.swift
//  formTests
//
//  Created by Clément on 17/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit
import Eureka
import RSKPlaceholderTextView

public class HoopTextViewCell: Cell<String>, CellType, UITextViewDelegate {
    
    @IBOutlet weak var rowTextView: RSKPlaceholderTextView!
    
    public override func setup() {
        super.setup()
        height = { UITableView.automaticDimension }
        rowTextView.text = (row as! HoopTextViewRow).content
        rowTextView.placeholder = (row as! HoopTextViewRow).placeholder as NSString?
        rowTextView.isSelectable = (row as! HoopTextViewRow).isSelectable as Bool
        rowTextView.delegate = self
    }
    
    public override func update() {
        super.update()
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        if let tableView = formViewController()?.tableView {
            let currentOffset = tableView.contentOffset
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
            tableView.setContentOffset(currentOffset, animated: false)
        }
        (row as! HoopTextViewRow).value = textView.text
    }
}

public final class HoopTextViewRow: Row<HoopTextViewCell>, RowType {
    
    public var content: String?
    public var placeholder: String?
    public var isSelectable: Bool = true
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<HoopTextViewCell>(nibName: "HoopTextViewCell")
    }
}
