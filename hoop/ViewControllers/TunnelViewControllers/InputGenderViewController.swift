//
//  InputSexViewController.swift
//  hoop
//
//  Created by Clément on 18/04/2018.
//  Copyright © 2018 the hoop company. All rights reserved.
//

import UIKit

class InputGenderViewController: UIViewController {
    
    var isFemme: Bool!

    @IBOutlet weak var femme: UIButton!
    @IBOutlet weak var homme: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let gender = AppDelegate.me?.gender {
            isFemme = gender == 2
            if (isFemme!) {
                femme.backgroundColor = UIColor.hoopRedColor
                homme.backgroundColor = UIColor.hoopRedColor.withAlphaComponent(0.6)
            } else {
                femme.backgroundColor = UIColor.hoopRedColor.withAlphaComponent(0.6)
                homme.backgroundColor = UIColor.hoopRedColor
            }
            continueButton.backgroundColor = UIColor.hoopRedColor
            continueButton.isEnabled = true
        } else {
            femme.backgroundColor = UIColor.hoopRedColor.withAlphaComponent(0.6)
            homme.backgroundColor = UIColor.hoopRedColor.withAlphaComponent(0.6)
            continueButton.backgroundColor = UIColor.hoopRedColor.withAlphaComponent(0.6)
            continueButton.isEnabled = false
            
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func continueAction(_ sender: Any) {
        if let me = AppDelegate.me {
            if isFemme {
                me.gender = 2
            } else {
                me.gender = 1
            }
            me.save()
        }
        if let vc = try? Router.shared.matchControllerFromStoryboard("/inputEmail", storyboardName: "Main") {
            self.navigationController?.pushViewController(vc as! UIViewController, animated: true)
        }
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func femmeAction(_ sender: Any) {
        continueButton.backgroundColor = UIColor.hoopRedColor
        femme.backgroundColor = UIColor.hoopRedColor
        homme.backgroundColor = UIColor.hoopRedColor.withAlphaComponent(0.6)
        isFemme = true
        continueButton.isEnabled = true
    }

    @IBAction func hommeAction(_ sender: Any) {
        continueButton.backgroundColor = UIColor.hoopRedColor
        femme.backgroundColor = UIColor.hoopRedColor.withAlphaComponent(0.6)
        homme.backgroundColor = UIColor.hoopRedColor
        isFemme = false
        continueButton.isEnabled = true
    }
}
