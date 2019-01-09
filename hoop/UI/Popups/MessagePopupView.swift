//
//  MessagePopupView.swift
//  popupTests
//
//  Created by Clément on 14/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit
import SwiftEntryKit

class MessagePopupView: UIView {
    
    @IBOutlet weak var thumb: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var length: UILabel!
    @IBOutlet weak var messageView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var recipient: String = ""
    var recipientThumbString: String? = nil
    var sendClosure: (() -> ())? = nil
    var cancelClosure: (() -> ())? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init(_ recipient:String,_ thumbString:String,_ sendClosure: (()->())?,_ cancelClosure: (()->())? ) {
        super.init(frame: .zero)
        // Record all internals
        self.recipient = recipient
        self.recipientThumbString = thumbString
        self.sendClosure = sendClosure
        self.cancelClosure = cancelClosure
        setup()
    }
    
    private func setup() {
        fromNib()
        // configure view
        if let string = recipientThumbString {
            thumb.image = UIImage(named: string) // This gonna change
        }
        thumb.layer.cornerRadius = 35.0
        sendButton.addTarget(self, action: #selector(sendButtonPressed), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        clipsToBounds = true
        layer.cornerRadius = 5
    }
    
    @objc func sendButtonPressed() {
        self.sendClosure?()
    }
    
    @objc func cancelButtonPressed() {
        SwiftEntryKit.dismiss()
        self.cancelClosure?()
    }
}

