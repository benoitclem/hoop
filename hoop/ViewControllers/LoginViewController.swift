//
//  LoginViewController.swift
//  hoop
//
//  Created by Clément on 19/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit

class LoginViewController: VideoSplashViewController {
    
    let videoURL = NSURL.fileURL(withPath: Bundle.main.path(forResource: "loginVideoBackground", ofType: "mp4")!)
    let cguURL = URL(string: "http://www.ohmyhoop.com/cgu")
    let privacyURL = URL(string: "http://www.ohmyhoop.com/privacypolicy")
    let fbPermissions = ["public_profile", "email", "user_gender", "user_birthday", "user_photos", "user_likes"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoBackground()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func doFacebookLogin(_ sender: Any) {
        if let vc = try? Router.shared.matchControllerFromStoryboard("/map",storyboardName: "Main") {
            self.present(vc as! UIViewController, animated: true)
        }
    }
    
    func setupVideoBackground() {
        self.videoFrame = self.view.frame
        self.fillMode = .resizeAspectFill
        self.alwaysRepeat = true
        self.sound = false
        self.startTime = 0.0
        self.alpha = 0.6
        self.backgroundColor = HoopRedColor
        self.contentURL = self.videoURL
        self.restartForeground = true
    }
}
