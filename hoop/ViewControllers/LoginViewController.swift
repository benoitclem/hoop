//
//  LoginViewController.swift
//  hoop
//
//  Created by Clément on 19/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit
import Futures


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
        let connectionPromise = FacebookHandler.connect(with: fbPermissions, from: self)
        
        connectionPromise.whenRejected(on: .main) { error in

        }
        
        connectionPromise.whenFulfilled(on: .main) { result in
            //PopupProvider.showDoneNote()
            if let vc = try? Router.shared.matchControllerFromStoryboard("/map",storyboardName: "Main") {
                self.present(vc as! UIViewController, animated: true)
            }
        }
        
        connectionPromise.then(on: DispatchQueue.main) { info -> Future<Bool> in
            print("salut")
            print("info")
            return Future<Bool>()
        }
        
        connectionPromise.thenIfRejected(on: DispatchQueue.main) { error -> Future<Bool> in
            print("salut")
            var message = ""
            switch (error as NSError).code {
            case FacebookHandler.FB_ERROR_BASE:
                message = "Error occured"
            case FacebookHandler.FB_ERROR_CANCELED:
                message = "User canceled"
            case FacebookHandler.FB_ERROR_PERMISSION_DENIED:
                message = "Permission denied"
            default:
                message = "Unknow error occured"
            }
            PopupProvider.showDoneNote()
            return Future<Bool>()
        }
    }
    
    @IBAction func doAccountKitLogin(_ sender: Any) {
        
    }
    
//    @IBAction func loginButtonClicked() {
//        let login = FBSDKLoginManager.init()
//        login.logIn(withReadPermissions: self.permissions, from: self, handler: { result, error in
//            if error != nil {
//                self.showError(with: "Erreur", and: "Un problème est survenu durant le login, peux-tu verifier ta connection internet et recommencer l'operation")
//            } else if((result?.isCancelled)!) {
//                self.stopAnimating()
//                login.logOut()
//                // self.showError(with: "Permissions", and: "Il nous est necessaire de connaitre quelques informations pour que tu puisses poursuivre l'aventure hoop. On recommence?")
//
//            } else {
//                self.startAnimating()
//                // Look if user gave us the use of all permissions
//                if(FacebookHandler.allPermissionGranted()) {
//                    // Do the sync
//                    let _ = FacebookHandler.synchronizeFacebookBaseParameters(completionHandler: {_ in
//                        let infos = FacebookHandler.getFacebookInfos()
//                        // Gather all needed information for the hoop signup,
//                        self.hoopSignIn(with: infos)
//                    }, errorHandler: {_ in
//                        self.stopAnimating()
//                        login.logOut()
//                        self.showError(with: "Erreur", and: "Un problème est survenu durant le login, peux-tu verifier ta connection internet et recommencer l'operation")
//                    })
//                } else {
//                    self.stopAnimating()
//                    FBSDKLoginManager().logOut()
//                    self.showError(with: "Permissions", and: "Il nous est necessaire de connaitre quelques informations pour que tu puisses poursuivre l'aventure hoop. On recommence?")
//                }
//            }
//        })
//    }
    
}
