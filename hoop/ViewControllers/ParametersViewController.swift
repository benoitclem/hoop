//
//  ParametersViewController.swift
//  hoop
//
//  Created by Clément on 19/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit
import Eureka
import AccountKit

class ParametersViewController: NotifiableFormViewController {
    
    static let TAG_IMAGES = "me_images"
    static let TAG_DESCRIPTION = "me_description"
    static let TAG_I_WANT_MALE = "me_iWantMale"
    static let TAG_I_WANT_FEMALE = "me_iWantFemale"
    static let TAG_I_WANT_AGERANGE = "me_iWantAgeRange"
    
    let me: profile? = AppDelegate.me
    var picturesGotModified: Bool = false
    var profileGotModified: Bool = false
    var firstTimer: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let reached_map = me?.reached_map {
            firstTimer = !reached_map
        }
        
        let vcTitle = "parameter_vc_title".localized()
        var leftTitle: String? = "back".localized()
        var leftSelector: Selector? = #selector(ParametersViewController.endViewController(sender:))
        var rightTitle: String? = "end".localized()
        var rightSelector: Selector? = #selector(ParametersViewController.endViewController(sender:))
        
        // Comfigure viewController for firsttimer
        if (firstTimer) {
            // Force the profile to be uploaded at first time
            picturesGotModified = true
            profileGotModified = true
            leftTitle = nil
            leftSelector = nil
        } else {
            rightTitle = nil
            rightSelector = nil
        }
        
        self.setupHoopNavigationBar(vcTitle,
                                    leftTitle: leftTitle, leftSelector: leftSelector,
                                    rightTitle: rightTitle, rightSelector: rightSelector)
        
        self.tableView.backgroundColor = .hoopTableGrayColor
        self.tableView.separatorStyle = .none
        
        var emailRules = RuleSet<String>()
        emailRules.add(rule: RuleEmail())
        
        // [SECTION] Pictures photo
        form +++ Section("Mes photos")
            <<< ImageCollectionViewRow() { row in
                row.tag = ParametersViewController.TAG_IMAGES
                row.value = [UIImage]()
                row.delegate = self
                if let images = self.me?.pictures_images {
                    for image in images {
                        row.value?.append(image)
                    }
                }
            }.onChange { row in
                print("got changes")
                self.picturesGotModified = true
                print(row.value)
            }
        
        // [SECTION] Prénom Age
        form +++ Section("Informations")
            <<< HoopLabelRow() { row in
                row.hidden = Condition.function([], { _ in
                    return self.me?.name == nil
                })
                if let name = self.me?.name {
                    row.title = name
                }
            }
            <<< HoopLabelRow() { row in
                row.hidden = Condition.function([], { _ in
                    return self.me?.age == nil
                })
                if let age = self.me?.age {
                    row.title = String(age)
                }
            }

        // [SECTION] A propos de moi
        form +++ Section("À propos de moi")
            <<< HoopTextViewRow() { row in
                row.tag = ParametersViewController.TAG_DESCRIPTION
                row.content = me?.description
                row.placeholder = "write something here"
            }.onChange{ _ in
                self.profileGotModified = true
            }
        
        
        
        // [SECTION] Je souhaite rencontrer
        form +++ Section("Je souhaite rencontrer")
            <<< HoopSwitchRow() { row in
                row.tag = ParametersViewController.TAG_I_WANT_FEMALE
                row.labelText = "Femme"
                row.value = ((self.me?.sexualOrientation ?? 0b10) & 0b10) == 2
            }.onChange{ _ in
                    self.profileGotModified = true
            }
            <<< HoopSwitchRow() { row in
                row.tag = ParametersViewController.TAG_I_WANT_MALE
                row.labelText = "Homme"
                row.value = ((self.me?.sexualOrientation ?? 0b01) & 0b01) == 1
            }.onChange{ _ in
                    self.profileGotModified = true
            }
            <<< HoopRangeRow() { row in
                row.tag = ParametersViewController.TAG_I_WANT_AGERANGE
                row.labelText = "Tranche d'age"
                if let min = self.me?.age_min, let max = self.me?.age_max {
                    row.value = Range(min: 18,low: Double(min),upp: Double(max),max: 55)
                } else {
                    row.value = Range(min: 18,low: 18,upp: 55,max: 55)
                }
            }.onChange{ _ in
                self.profileGotModified = true
            }
            
        if (!firstTimer) {
            form +++ Section()
                <<< HoopLabelRow() { row in
                    var style = HoopLabelRowStyle()
                    style.bgColor = .hoopGreenColor
                    style.txtColor = UIColor.white
                    style.txtAlignement = NSTextAlignment.center
                    row.labelText = "partager"
                    row.labelStyle = style
                    }.onCellSelection { cell, row in
                        //row.title = "action 1"
                        print(self.form.values())
                    }
            form +++ Section()
                <<< HoopLabelRow() { row in
                    var style = HoopLabelRowStyle()
                    row.labelText = "besoin d'aide?"
                    style.txtAlignement = NSTextAlignment.center
                    row.labelStyle = style
                }.onCellSelection { cell, row in
                    if let vc = try? Router.shared.matchControllerFromStoryboard("/faq", storyboardName: "Main") {
                        self.navigationController?.pushViewController(vc as! UIViewController, animated: true)
                    }
                }
                <<< HoopLabelRow() { row in
                    var style = HoopLabelRowStyle()
                    row.labelText = "tutorial"
                    style.txtAlignement = NSTextAlignment.center
                    row.labelStyle = style
                }.onCellSelection { cell, row in
                        print(row.labelText)
                        
                }
            
            form +++ Section("mention légales")
                <<< HoopLabelRow() { row in
                    var style = HoopLabelRowStyle()
                    style.accessoryType = .disclosureIndicator
                    row.labelText = "politique de confidentialité"
                    row.labelStyle = style
                    }.onCellSelection { cell, row in
                        //row.title = "action 1"
                        print(row.labelText)
                        if let vc = try? Router.shared.matchControllerFromStoryboard("/web/Confidentialite", storyboardName: "Main") {
                            self.navigationController?.pushViewController(vc as! UIViewController, animated: true)
                        }
                }
                <<< HoopLabelRow() { row in
                    var style = HoopLabelRowStyle()
                    style.accessoryType = .disclosureIndicator
                    row.labelText = "condition générales"
                    row.labelStyle = style
                    }.onCellSelection { cell, row in
                        //row.title = "action 1"
                        print(row.labelText)
                        if let vc = try? Router.shared.matchControllerFromStoryboard("/web/CGU", storyboardName: "Main") {
                            self.navigationController?.pushViewController(vc as! UIViewController, animated: true)
                        }
                }
                <<< HoopLabelRow() { row in
                    var style = HoopLabelRowStyle()
                    style.accessoryType = .disclosureIndicator
                    row.labelText = "licences"
                    row.labelStyle = style
                }.onCellSelection { cell, row in
                    //row.title = "action 1"
                    print(row.labelText)
                    if let vc = try? Router.shared.matchControllerFromStoryboard("/web/Licences", storyboardName: "Main") {
                        self.navigationController?.pushViewController(vc as! UIViewController, animated: true)
                    }
                }
            form +++ Section("quitter")
                <<< HoopLabelRow() { row in
                    var style = HoopLabelRowStyle()
                    row.labelText = "se déconnecter"
                    style.txtAlignement = NSTextAlignment.center
                    row.labelStyle = style
                }.onCellSelection { cell, row in
                    // Call the logout for the specific login method
                    self.doLogout()
                }
                <<< HoopLabelRow() { row in
                    
                    var style = HoopLabelRowStyle()
                    row.labelText = "supprimer son compte"
                    style.txtAlignement = NSTextAlignment.center
                    row.labelStyle = style
                }.onCellSelection { cell, row in
                        //row.title = "action 1"
                        print(row.labelText)
                }
                
            form +++ Section("developper")
                <<< HoopLabelRow() { row in
                    
                    var style = HoopLabelRowStyle()
                    row.labelText = "vider les caches"
                    style.txtAlignement = NSTextAlignment.center
                    row.labelStyle = style
                    }.onCellSelection { cell, row in
                        if let pm = profileManager.get() {
                            pm.profiles.removeAll()
                            pm.save()
                        }
                        
                        if let cm = conversationManager.get() {
                            for conv in cm.conversations {
                                if let mm = messageManager.get(withKey: "storageKey\(conv.finalExpId)") {
                                    mm.messages.removeAll()
                                    mm.save()
                                }
                            }
                            cm.conversations.removeAll()
                            cm.th_conversations.removeAll()
                            cm.save()
                        }

                }
        }
    }
    
    override func didReceiveNotification(notification: Notification) {
        print("Map View Did receive notif")
        //let nData = notification.object as! notificationData
        let nData = notification.object as! notificationData
        PopupProvider.showMessageToast(with: nData, tapAction: { profileId in
            if self.profileGotModified || self.picturesGotModified {
                PopupProvider.showTwoChoicesPopup(icon: UIImage(named:"sadscreen")!, title: "Attention", content: "Si tu continue vers la notification, tes modifications serons perdues", okTitle: "continuer", nokTitle: "annuler", okClosure: {
                    self.jumpToProfile(withId: profileId)
                }, nokClosure: nil)
            } else {
                self.jumpToProfile(withId: profileId)
            }})
    }
    
    @objc func endViewController( sender: UIBarButtonItem) {
        // Will need to record stuffs here
        validateSaveUpload { updateDone in
            if(self.firstTimer) {
                if let vc = try? Router.shared.matchControllerFromStoryboard("/map", storyboardName: "Main") {
                    self.navigationController?.replaceRootViewControllerBy(vc: vc as! UIViewController)
                }
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func doLogout() {
        if let me = AppDelegate.me {
            // kill the me token stuff and record

            // check the token validity to know from where we came
            if let _ = me.fb_token {
                FacebookHandler.logout()
            } else {
                let  _accountKit = AKFAccountKit(responseType: .accessToken)
                _accountKit.logOut()
            }
            // Clean the me
            me.token = nil
            me.fb_token = nil
            me.ak_token = nil
            me.save()
            // Replace base view (this is quite violent but reset the app as it has been just launched)
            (UIApplication.shared.delegate as! AppDelegate).showLogin()
        }
    }
    
    func validateSaveUpload(callback: @escaping (Bool) -> Void){
        // Retrieve the values from form
        let formValues = form.values()

        // ============
        // Checks & Record part
        
        let images = formValues[ParametersViewController.TAG_IMAGES]
        if images != nil {
            if (images as! [UIImage]).count == 0 {
                PopupProvider.showInformPopup(with: UIImage(named: "sadscreen")!, "Informations manquantes", "Une photo de toi est necessaire.", "ok", {print("action")})
                return
            }
        } else {
            PopupProvider.showInformPopup(with: UIImage(named: "sadscreen")!, "Informations manquantes", "il faut une image minimum", "ok", {print("action")})
            return
        }
        me?.pictures_images = images as! [UIImage]
        
        // Here i can retrieve and downcast
        if let female = formValues[ParametersViewController.TAG_I_WANT_FEMALE] as! Bool?, let male = formValues[ParametersViewController.TAG_I_WANT_MALE] as! Bool? {
            let orientation = (female ? 2 : 0) + (male ? 1 : 0)
            if orientation != 0 {
                me?.sexualOrientation = orientation
            } else {
                PopupProvider.showInformPopup(with: UIImage(named: "sadscreen")!, "Informations manquantes", "Un choix de genre est necessaire, tu peux choisir l'un ou l'autre ou les deux.", "ok", {print("action")})
                return
            }
        }
        
        if let description = formValues[ParametersViewController.TAG_DESCRIPTION] as! String? {
            me?.description = description
        }
        
        if let ageRange = formValues[ParametersViewController.TAG_I_WANT_AGERANGE] as! Range? {
            me?.age_min = Int(ageRange.low)
            me?.age_max = Int(ageRange.upp)
        }
        
        me?.save()
        
        // =============
        if self.profileGotModified || self.picturesGotModified {
            var data = [String:Any]()
            // Optional upload Part
            if self.profileGotModified {
                if let profileData = me?.getProfileDataForUpload() {
                    data += profileData
                }
            }
            if self.picturesGotModified {
                if let profilePictureData = me?.getProfilePicturesForUpload() {
                    data += profilePictureData
                }
            }
            let promise = HoopNetworkApi.sharedInstance.postHoopProfile(withData: data)
            promise.whenFulfilled(on: .main) { done in
                if done {
                    print("update ok")
                    callback(true)
                }
            }
            promise.whenRejected(on: .main) { error in
                PopupProvider.showErrorNote(error.localizedDescription)
            }
        } else {
            callback(false)
        }
        
    }
    
    // Nice and fast way to customize the header view
    func tableView(_: UITableView, willDisplayHeaderView view: UIView, forSection: Int) {
        
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.textColor = .hoopRedColor
            view.textLabel?.font = .MainFontMedium(ofSize: 15.0)
            view.textLabel?.text = view.textLabel?.text?.lowercased()
        }
    }

    func jumpToProfile(withId profileId: Int){
        if let chatVC = try? Router.shared.matchControllerFromStoryboard("/chat/\(profileId)",storyboardName: "Main") as! UIViewController,
            let convVC = try? Router.shared.matchControllerFromStoryboard("/conversations",storyboardName: "Main") as! UIViewController {
            if var vcs = self.navigationController?.viewControllers {
                let _ = vcs.popLast()
                vcs.append(convVC)
                vcs.append(chatVC)
                self.navigationController?.setViewControllers(vcs, animated: true)
            }
        }
    }

}

extension ParametersViewController: DisplayPictureSourceProtocol {
    func showViewController(_ vc: UIViewController) {
        self.present(vc, animated: true, completion: nil)
    }
    
    func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
}

