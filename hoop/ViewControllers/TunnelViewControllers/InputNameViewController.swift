//
//  InputNameViewController.swift
//  hoop
//
//  Created by Clément on 18/04/2018.
//  Copyright © 2018 the hoop company. All rights reserved.
//

import UIKit

class InputNameViewController: UIViewController {
    
    @IBOutlet weak var prenomTextfield: UITextField!
    @IBOutlet weak var continuebutton: UIButton!
    
    override func viewDidLoad() {
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Recall last data
        // Recall last data
        if let name = AppDelegate.me?.name {
            prenomTextfield.text = name
            continuebutton.backgroundColor = UIColor.hoopRedColor
            continuebutton.isEnabled = true
        } else {
            continuebutton.backgroundColor = UIColor.hoopRedColor.withAlphaComponent(0.6)
            continuebutton.isEnabled = false
        }
        
        self.prenomTextfield.becomeFirstResponder()
        self.prenomTextfield.delegate = self
        self.prenomTextfield.addTarget(self, action: #selector(InputNameViewController.textFieldValueDidChange), for: .editingChanged)

    }
    
    @IBAction func continueAction(_ sender: Any) {
        var name = prenomTextfield.text!
        name.trim()
        name.capitalizeFirstLetter()
        if let me = AppDelegate.me {
            me.name = name
            me.save()
        }
        if let vc = try? Router.shared.matchControllerFromStoryboard("/inputAge", storyboardName: "Main") {
            self.navigationController?.pushViewController(vc as! UIViewController, animated: true)
        }
    }
    
}

extension InputNameViewController: UITextFieldDelegate {
    
    @objc func textFieldValueDidChange(_ textField: UITextField) {
        if (textField.text?.count)! > 1 {
            self.continuebutton.isEnabled = true
            self.continuebutton.backgroundColor = UIColor.hoopRedColor
        } else {
            self.continuebutton.isEnabled = false
            self.continuebutton.backgroundColor = UIColor.hoopRedColor.withAlphaComponent(0.6)
        }
    }

}
