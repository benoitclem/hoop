//
//  InputEmailViewController.swift
//  hoop
//
//  Created by Clément on 18/04/2018.
//  Copyright © 2018 the hoop company. All rights reserved.
//

import UIKit

class InputEmailViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var finishButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Recall last data
        if let email = UserDefaults.standard.string(forKey: "email") {
            self.emailTextField.text = email
            self.finishButton.isEnabled = true
            self.finishButton.backgroundColor = UIColor.hoopRedColor
        } else {
            finishButton.isEnabled = false
            self.finishButton.backgroundColor = UIColor.hoopRedColor.withAlphaComponent(0.6)
        }
        
        // Take the focus
        self.emailTextField.becomeFirstResponder()
        self.emailTextField.addTarget(self, action: #selector(InputEmailViewController.textFieldValueDidChange), for: .editingChanged)
        self.emailTextField.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func finishAction(_ sender: Any) {
        if let email = emailTextField.text {
            if let me = AppDelegate.me {
                me.email = email
                me.save()
            }
            if let vc = try? Router.shared.matchControllerFromStoryboard("/parameters", storyboardName: "Main") {
                self.navigationController?.replaceRootViewControllerBy(vc: vc as! UIViewController)
            }
        }
        
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension InputEmailViewController: UITextFieldDelegate {
    
    @objc func textFieldValueDidChange(_ textField: UITextField) {
        if (textField.text?.count)! > 1 {
            if self.isValidEmail(testStr: textField.text!) {
                self.finishButton.isEnabled = true
                self.finishButton.backgroundColor = UIColor.hoopRedColor
                return
            }
        }
        self.finishButton.isEnabled = false
        self.finishButton.backgroundColor = UIColor.hoopRedColor.withAlphaComponent(0.6)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
}
