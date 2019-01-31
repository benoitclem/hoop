//
//  LoginViewController.swift
//  hoop
//
//  Created by Clément on 19/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit
import Futures
import AccountKit
import FacebookCore
import FacebookLogin
//import SwiftyJSON

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
        setupUserInterface()
        setupVideoBackground()
        setupLegals()
        // Do any additional setup after loading the view.
    }
    
    func setupUserInterface() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
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
    
    enum ScreenToShow: String {
        case parameters = "parameters"
        case tunnel = "tunnel"
        case map = "map"
    }
    
    func returnFutureWith(_ screen:ScreenToShow) -> Future<ScreenToShow> {
        let p = Promise<ScreenToShow>()
        p.fulfill(screen)
        return p.future
    }
    
    @IBAction func doFacebookLogin(_ sender: Any) {
        
        let future = FacebookHandler.connect(with: fbPermissions, from: self).then { info -> Future<fbme> in
            return FacebookHandler.getMyProfile()
        }.then { fbProfile -> Future<profile> in
            return HoopNetworkApi.sharedInstance.signUpForFb(with: fbProfile)
        }.then(on: .main){ me -> Future<ScreenToShow> in
            
            if me.pictures_images.count == 0 {
                // Go get the images
                return FacebookHandler.getMyProfilePictures(fromAlbum: me.fb_profile_alb_id).then { urls -> Future<Bool> in
                    return  HoopNetworkApi.sharedInstance.getProfilePictures(fromUrls: urls)
                }.then { done -> Future<ScreenToShow> in
                    return self.returnFutureWith(.parameters)
                }
            } else {
                if let _ =  me.reached_map {
                    return self.returnFutureWith(.map)
                } else {
                    return self.returnFutureWith(.parameters)
                }
            }
        }
        
        // This future
        future.whenFulfilled(on: .main) { screen in
            switch screen {
            case .map:
                if let vc = try? Router.shared.matchControllerFromStoryboard("/map", storyboardName: "Main") {
                    self.navigationController?.replaceRootViewControllerBy(vc: vc as! UIViewController)
                }
            case .parameters:
                if let vc = try? Router.shared.matchControllerFromStoryboard("/parameters", storyboardName: "Main") {
                    self.navigationController?.replaceRootViewControllerBy(vc: vc as! UIViewController)
                }
            // This is just to avoid the compiler to complain (this case never happen in fb connection)
            case .tunnel:
                if let vc = try? Router.shared.matchControllerFromStoryboard("/inputName", storyboardName: "Main") {
                    self.navigationController?.replaceRootViewControllerBy(vc: vc as! UIViewController)
                }
            }
        }
        
        future.whenRejected(on: .main) { error in
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
            PopupProvider.showInformPopup(with: UIImage(named: "sadscreen")!, "erreur", message, "button") {
                print("action")
            }
        }

    }
    
    @IBAction func doAccountKitLogin(_ sender: Any) {

        let inputState = NSUUID().uuidString
        let theme:AKFTheme = AKFTheme.default()
        theme.headerBackgroundColor = UIColor.hoopGreenColor
        theme.headerTextColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        theme.iconColor = UIColor(red: 0.325, green: 0.557, blue: 1, alpha: 1)
        theme.inputTextColor = UIColor(white: 0.4, alpha: 1.0)
        theme.inputBackgroundColor = UIColor.hoopGreenColor.withAlphaComponent(0.2)
        theme.inputBorderColor = UIColor.clear
        theme.statusBarStyle = .lightContent
        theme.textColor = UIColor(white: 0.3, alpha: 1.0)
        theme.titleColor = UIColor(red: 0.247, green: 0.247, blue: 0.247, alpha: 1)
        theme.buttonBackgroundColor = UIColor.hoopGreenColor
        theme.buttonBorderColor = UIColor.clear
        theme.buttonDisabledBackgroundColor = UIColor.hoopGreenColor.withAlphaComponent(0.2)
        theme.buttonDisabledBorderColor = UIColor.clear
        let accountKit = AKFAccountKit(responseType: .accessToken)
        let vc: AKFViewController = accountKit.viewControllerForPhoneLogin(with: nil, state: inputState) as! AKFViewController
        vc.setTheme(theme)
        vc.delegate = self
        self.present(vc as! UIViewController, animated: true, completion: nil)
    }
    
    
}


extension LoginViewController: AKFViewControllerDelegate {
    
    func viewController(_ viewController: (UIViewController & AKFViewController)!, didCompleteLoginWith accessToken: AKFAccessToken!, state: String!) {

        let future = HoopNetworkApi.sharedInstance.signUpForAK(with: accessToken.accountID)
        
        future.whenFulfilled(on: .main) { done in
            // TODO: Go to map / parameters / tunnel
            if let _ = AppDelegate.me?.reached_map {
                if let vc = try? Router.shared.matchControllerFromStoryboard("/map", storyboardName: "Main") {
                    self.navigationController?.replaceRootViewControllerBy(vc: vc as! UIViewController)
                
                }
            } else {
                let name =  AppDelegate.me?.name
                let age = AppDelegate.me?.age
                let email = AppDelegate.me?.email
                let gender = AppDelegate.me?.gender
                if name == nil || age == nil || email == nil || gender == nil {
                    if let vc = try? Router.shared.matchControllerFromStoryboard("/inputName", storyboardName: "Main") {
                        self.navigationController?.replaceRootViewControllerBy(vc: vc as! UIViewController)
                    }
                } else {
                    if let vc = try? Router.shared.matchControllerFromStoryboard("/parameters", storyboardName: "Main") {
                        self.navigationController?.replaceRootViewControllerBy(vc: vc as! UIViewController)
                    }
                }
            }

        }
       
        future.whenRejected(on: .main) { error in
            var message = "error occured"
            PopupProvider.showInformPopup(with: UIImage(named: "sadscreen")!, "erreur", message, "button") {
                print("action")
            }
        }
    }
    
}
