//
//  LoginViewController.swift
//  hoop
//
//  Created by Clément on 19/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit
import Futures
import FacebookCore
import FacebookLogin
import SwiftyJSON

class LoginViewController: VideoSplashViewController {
    
    @IBOutlet weak var legalLabel: UILabel!
    
    let videoURL = NSURL.fileURL(withPath: Bundle.main.path(forResource: "loginVideoBackground", ofType: "mp4")!)
    let cguURL = URL(string: "http://www.ohmyhoop.com/cgu")
    let privacyURL = URL(string: "http://www.ohmyhoop.com/privacypolicy")
    let fbPermissions:[ReadPermission] = [.publicProfile,
                                          .email,
                                          .userGender,
                                          .userBirthday,
                                          .userPhotos,
                                          .userLikes]
    
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
//        if let _ = AccessToken.current {
//            FacebookHandler.getMyProfile()
//        }
        
        let loginPromise = FacebookHandler.connect(with: fbPermissions, from: self)
                
//        loginPromise.whenFulfilled { result in
//            //PopupProvider.showDoneNote()
//            if let vc = try? Router.shared.matchControllerFromStoryboard("/map",storyboardName: "Main") {
//                self.present(vc as! UIViewController, animated: true)
//            }
//        }
        
        loginPromise.whenRejected(on: .main)  { error in
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
            PopupProvider.showInformPopup(with: UIImage(named: "sadscreen")!, "titre", "description", "button") {
                print("action")
            }
        }
        
        let profilPromise = loginPromise.then { info -> Future<fbme> in
            return FacebookHandler.getMyProfile()
        }
        
        profilPromise.whenRejected(on: .main) { error  in
            PopupProvider.showInformPopup(with: UIImage(named: "sadscreen")!, "titre", "description", "button") {
                print("action")
            }
        }
        
        let signupPromise = profilPromise.then { fbProfile -> Future<profile> in
            return HoopNetworkApi.sharedInstance.signUp(with: fbProfile)
        }
        
        signupPromise.whenFulfilled(on: .main){ profile in
            print(profile)
            if let vc = try? Router.shared.matchControllerFromStoryboard("/map",storyboardName: "Main") {
                self.present(vc as! UIViewController, animated: true)
            }
        }
        
        signupPromise.whenRejected(on: .main){ error in
            PopupProvider.showInformPopup(with: UIImage(named: "sadscreen")!, "titre", "description", "button") {
                print("action")
            }
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
