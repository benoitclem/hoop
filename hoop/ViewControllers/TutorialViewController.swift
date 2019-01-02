//
//  TutorialViewController.swift
//  hoop
//
//  Created by Clément on 19/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, UINavigationBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // addNavigationBar()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func skipAction(_ sender: Any) {
        // Update tutorial sawn flag
        let defaults = Defaults()
        if let retrievedMe = defaults.get(for: .me) {
            let me = retrievedMe
            me.saw_tutorial = true
            defaults.set(me, for: .me)
        }
        if let vc = try? Router.shared.matchControllerFromStoryboard("/parameters", storyboardName: "Main") {
            self.present(vc as! UIViewController, animated: true)
        }
    }
    
}
