//
//  InputTextFieldBar.swift
//  hoop
//
//  Created by Clément on 27/04/2017.
//  Copyright © 2017 the hoop company. All rights reserved.
//

import UIKit

class InputTextFieldBar: UIView {
    @IBOutlet weak var EnclosureView: UIView!
    @IBOutlet weak var TextView: UITextView!
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var PlaceHolderLabel: UILabel!
    
    var view: UIView!
    var requestedSize: CGRect!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.requestedSize = frame
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        // Apply the requested frame size to thhe loaded nib
        view.frame = self.requestedSize
        self.autoresizingMask = .flexibleHeight;
        self.TextView.translatesAutoresizingMaskIntoConstraints = false
        self.EnclosureView.layer.cornerRadius = 33.0/2
        self.EnclosureView.clipsToBounds = true
        self.TextView.isScrollEnabled = false
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "InputTextFieldBar", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    override var intrinsicContentSize: CGSize {
        //print(super.intrinsicContentSize)
        // Calculate intrinsicContentSize that will fit all the text
        let textSize = self.TextView.sizeThatFits(CGSize(width: self.TextView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        //print("intrinsicContentSize computed",textSize.height)
        return CGSize(width: self.bounds.width, height: textSize.height)
    }
    
}
