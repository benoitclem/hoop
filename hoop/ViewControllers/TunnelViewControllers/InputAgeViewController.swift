//
//  InputAgeViewCellViewController.swift
//  hoop
//
//  Created by Clément on 18/04/2018.
//  Copyright © 2018 the hoop company. All rights reserved.
//

import UIKit

class InputAgeViewController: UIViewController {
    
    var bdayString:String? = nil
    var dob: Date? = nil
    @IBOutlet weak var bDayTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dp = UIDatePicker.init()
        dp.datePickerMode = .date
        
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let minimumDate = calendar.date(byAdding: .year, value: -18, to: Date.init())
        
        // Recall last data
        if let date = AppDelegate.me?.dob {
            dp.date = date
            dob = date
            self.bDayTextField.text = DateFormatter.ddMMMyyyy.string(from: date)
            continueButton.backgroundColor = UIColor.hoopRedColor
            continueButton.isEnabled = true
        } else {
            continueButton.backgroundColor = UIColor.hoopRedColor.withAlphaComponent(0.6)
            continueButton.isEnabled = false
        }
        
        dp.maximumDate = Date.init()
        dp.addTarget(self, action: #selector(InputAgeViewController.datePicked), for: .valueChanged)
        
        self.bDayTextField.becomeFirstResponder()
        self.bDayTextField.inputView = dp
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func continueAction(_ sender: Any) {
        if let me = AppDelegate.me {
            me.dob = dob
            me.save()
        }
        if let vc = try? Router.shared.matchControllerFromStoryboard("/inputGender", storyboardName: "Main") {
            self.navigationController?.pushViewController(vc as! UIViewController, animated: true)
        }
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

    @objc func datePicked(sender: UIDatePicker){
        dob = sender.date
        bDayTextField.text = DateFormatter.ddMMMyyyy.string(from: sender.date)
        continueButton.backgroundColor = UIColor.hoopRedColor
        continueButton.isEnabled = true
    }
}

