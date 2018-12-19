//
//  LoginViewController.swift
//  hoop
//
//  Created by Clément on 19/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func doFacebookLogin(_ sender: Any) {
        if let vc = try? Router.shared.matchControllerFromStoryboard("/map",storyboardName: "Main") {
            self.present(vc as! UIViewController, animated: true)
        }
    }
    

}
