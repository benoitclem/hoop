//
//  LoginViewController.swift
//  hoop
//
//  Created by Clément on 19/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit



class LoginViewController: VideoSplashViewController {
    
    @IBOutlet weak var legalLabel: UILabel!
    
    let videoURL = NSURL.fileURL(withPath: Bundle.main.path(forResource: "loginVideoBackground", ofType: "mp4")!)
    let cguURL = URL(string: "http://www.ohmyhoop.com/cgu")
    let privacyURL = URL(string: "http://www.ohmyhoop.com/privacypolicy")
    let fbPermissions = ["public_profile", "email", "user_gender", "user_birthday", "user_photos", "user_likes"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoBackground()
        setupLegals()
        // Do any additional setup after loading the view.
    }
    
    func setupVideoBackground() {
        self.videoFrame = self.view.frame
        self.fillMode = .resizeAspectFill
        self.alwaysRepeat = true
        self.sound = false
        self.startTime = 0.0
        self.alpha = 0.6
        self.backgroundColor = .hoopRedColor
        self.contentURL = self.videoURL
        self.restartForeground = true
    }
    
    func setupLegals() {
        // Legals
        legalLabel.attributedText = NSMutableAttributedString(string: "legals".localized())
        legalLabel.stylizeSubstring("cgu".localized(), .white, NSUnderlineStyle.single)
        legalLabel.stylizeSubstring("conf".localized(), .white, NSUnderlineStyle.single)
        legalLabel.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(LoginViewController.handleLegalTap)))
    }
    
    @objc func handleLegalTap(tap: UITapGestureRecognizer) {
        let rangeCgu = "legals".localized().range(of: "cgu".localized())!
        let rangeConf = "legals".localized().range(of: "conf".localized())!
        let cguLowerIndex = rangeCgu.lowerBound.encodedOffset
        //let cguUpperIndex = cguLowerIndex + "cgu".localized().count
        let cguRange = NSRange(location: cguLowerIndex, length: "cgu".localized().count)
        let confLowerIndex = rangeConf.lowerBound.encodedOffset
        //let confUpperIndex = confLowerIndex + "conf".localized().count
        let confRange = NSRange(location: confLowerIndex, length: "conf".localized().count)
        if tap.didTapAttributedTextInLabel(label: legalLabel, inRange: cguRange) {
            print(self.cguURL!)
            UIApplication.shared.open(self.cguURL!, options: [:], completionHandler: nil)
        } else if tap.didTapAttributedTextInLabel(label: legalLabel, inRange: confRange) {
            print(self.privacyURL!)
            UIApplication.shared.open(self.privacyURL!, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func doFacebookLogin(_ sender: Any) {
        if let vc = try? Router.shared.matchControllerFromStoryboard("/map",storyboardName: "Main") {
            self.present(vc as! UIViewController, animated: true)
        }
    }
}
