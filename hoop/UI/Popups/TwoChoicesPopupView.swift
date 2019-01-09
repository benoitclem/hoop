//
//  TwoChoicesPopupView.swift
//  hoop
//
//  Created by Clément on 09/01/2019.
//  Copyright © 2019 hoop. All rights reserved.
//

import Foundation
import SwiftEntryKit

class TwoChoicesPopupView: UIView {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    var iconImage: UIImage? = nil
    var titleString: String? = nil
    var contentString: String? = nil
    var okButtonTitleString: String? = nil
    var nokButtonTitleString: String? = nil
    var okButtonClosure: (() -> ())? = nil
    var nokButtonClosure: (() -> ())? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init(icon:UIImage?,
         title:String,
         content:String,
         okTitle:String?,
         nokTitle:String?,
         okClosure: (()->())?,
         nokClosure: (()->())? ) {
        super.init(frame: .zero)
        // Record all internals
        iconImage = icon
        titleString = title
        contentString = content
        okButtonTitleString = okTitle
        nokButtonTitleString = nokTitle
        okButtonClosure = okClosure
        nokButtonClosure = nokClosure
        // Setup everythong
        setup()
    }
    
    private func setup() {
        fromNib()
        // configure view
        if let img = iconImage {
            icon.image = img
        }
        if let str = titleString {
            title.text = str
        }
        if let str = contentString {
            content.text = str
        }
        if let str = okButtonTitleString {
            sendButton.setTitle(str, for: .normal)
        } else {
            sendButton.isHidden = true
        }
        if let str = nokButtonTitleString {
            cancelButton.setTitle(str, for: .normal)
        } else {
            cancelButton.isHidden = true
        }
        sendButton.addTarget(self, action: #selector(sendButtonPressed), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        clipsToBounds = true
        layer.cornerRadius = 5
    }
    
    @objc func sendButtonPressed() {
        SwiftEntryKit.dismiss()
        self.okButtonClosure?()
    }
    
    @objc func cancelButtonPressed() {
        SwiftEntryKit.dismiss()
        self.nokButtonClosure?()
    }
}
