//
//  MessagePopupView.swift
//  popupTests
//
//  Created by Clément on 14/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit
import SwiftEntryKit
import RSKPlaceholderTextView

class MessagePopupView: UIView {
    
    @IBOutlet weak var thumb: UIImageView!
    @IBOutlet weak var recepientLabel: UILabel!
    @IBOutlet weak var lenLabel: UILabel!
    @IBOutlet weak var messageTextView: RSKPlaceholderTextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var recipient: String = ""
    var recipientThumbUrl: URL? = nil
    var sendClosure: ((_ message:String) -> ())? = nil
    var cancelClosure: (() -> ())? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init(_ recipient:String,_ thumbUrl:URL?,_ sendClosure: ((_ message:String)->())?,_ cancelClosure: (()->())? ) {
        super.init(frame: .zero)
        // Record all internals
        self.recipient = recipient
        self.recipientThumbUrl = thumbUrl
        self.sendClosure = sendClosure
        self.cancelClosure = cancelClosure
        setup()
    }
    
    private func setup() {
        fromNib()
        
        // configure view
        if let url = recipientThumbUrl {
            thumb.kf.setImage(with: url)
        }
        thumb.layer.cornerRadius = 35.0
        recepientLabel.text = recipient
        
        lenLabel.text = "0/144"
        //messageTextView.placeholder = "un petit message pour commencer"
        messageTextView.delegate = self
        
        sendButton.addTarget(self, action: #selector(sendButtonPressed), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        
        self.sendButton.backgroundColor = UIColor.hoopGreenColor.grayout()
        self.sendButton.isEnabled = false
        
        clipsToBounds = true
        layer.cornerRadius = 5
        
    }
    
    @objc func sendButtonPressed() {
        SwiftEntryKit.dismiss()
        self.sendClosure?(messageTextView.text)
    }
    
    @objc func cancelButtonPressed() {
        SwiftEntryKit.dismiss()
        self.cancelClosure?()
    }
    
}

extension MessagePopupView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if(textView.text.count == 0) {
            if(sendButton.isEnabled == true) {
                UIView.animate(withDuration: 0.1, animations: {
                    self.sendButton.backgroundColor = UIColor.hoopGreenColor.grayout()
                    //self.SendButton.titleLabel?.textColor =  UIColor.white.dimout()
                    self.sendButton.layoutSubviews()
                    self.sendButton.isEnabled = false
                })
            }
        } else {
            if(sendButton.isEnabled == false) {
                UIView.animate(withDuration: 0.1, animations: {
                    self.sendButton.backgroundColor = UIColor.hoopGreenColor
                    self.sendButton.titleLabel?.textColor =  UIColor.white
                    self.sendButton.layoutSubviews()
                    self.sendButton.isEnabled = true
                })
            }
        }
        let c = textView.text.count
        lenLabel.text = "\(c)/144"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        if(text == "\n") {
            messageTextView.resignFirstResponder()
            return false
        }
        let numberOfChars = newText.count // for Swift use count(newText)
        return numberOfChars <= 144;
    }
    
}

