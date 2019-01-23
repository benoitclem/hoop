//
//  ChatHeaderView.swift
//  hoop
//
//  Created by Clément on 23/01/2019.
//  Copyright © 2019 hoop. All rights reserved.
//

import UIKit

class ChatHeaderView: UIView {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    
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
        self.profileImageView.layer.cornerRadius = 45.0/2
        self.profileImageView.clipsToBounds = true
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ChatHeaderView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
}
