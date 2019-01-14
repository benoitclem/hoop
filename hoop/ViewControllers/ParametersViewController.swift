//
//  ParametersViewController.swift
//  hoop
//
//  Created by Clément on 19/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit
import Eureka

class ParametersViewController: FormViewController {
    
    static let TAG_IMAGES = "me_images"
    static let TAG_DESCRIPTION = "me_description"
    static let TAG_I_WANT_MALE = "me_iWantMale"
    static let TAG_I_WANT_FEMALE = "me_iWantFemale"
    static let TAG_I_WANT_AGERANGE = "me_iWantAgeRange"
    
    let me: profile? = AppDelegate.me
    var firstTimer: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let reached_map = me?.reached_map {
            firstTimer = !reached_map
        }
        
        let vcTitle = "parameter_vc_title".localized()
        var leftTitle: String? = "back".localized()
        var leftSelector: Selector? = #selector(ParametersViewController.leftTarget(sender:))
        var rightTitle = "record".localized()
        let rightSelector = #selector(ParametersViewController.rightTarget(sender:))
        
        if (firstTimer) {
            leftTitle = nil
            leftSelector = nil
            rightTitle = "end".localized()
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
                if let images = self.me?.pictures_images {
                    for image in images {
                        row.value?.append(image)
                    }
                }
            }.onChange { row in
                print("got changes")
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
            }
        
        
        
        // [SECTION] Je souhaite rencontrer
        form +++ Section("Je souhaite rencontrer")
            <<< HoopSwitchRow() { row in
                row.tag = ParametersViewController.TAG_I_WANT_FEMALE
                row.labelText = "Femme"
                row.value = ((self.me?.sexualOrientation ?? 0b10) & 0b10) == 2
            }
            <<< HoopSwitchRow() { row in
                row.tag = ParametersViewController.TAG_I_WANT_MALE
                row.labelText = "Homme"
                row.value = ((self.me?.sexualOrientation ?? 0b01) & 0b01) == 1
            }
            <<< HoopRangeRow() { row in
                row.tag = ParametersViewController.TAG_I_WANT_AGERANGE
                row.labelText = "Tranche d'age"
                if let min = self.me?.age_min, let max = self.me?.age_max {
                    row.value = Range(min: 18,low: Double(min),upp: Double(max),max: 55)
                } else {
                    row.value = Range(min: 18,low: 18,upp: 55,max: 55)
                }
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
                        //row.title = "action 1"
                        print(row.labelText)
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
        }
    }
    
    @objc func leftTarget( sender: UIBarButtonItem) {
        print("cancel")
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func rightTarget( sender: UIBarButtonItem) {
        print("done")

        // Will need to record stuffs here
        validateAndSave()
        
        if(firstTimer) {
            if let vc = try? Router.shared.matchControllerFromStoryboard("/map", storyboardName: "Main") {
                self.navigationController?.replaceRootViewControllerBy(vc: vc as! MapViewController)
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }

        /*
        */
    }
    
    func validateAndSave() -> Bool {
        let formValues = form.values()
        print(formValues)
        
        // ===========
        // Checks
        
        let images = formValues[ParametersViewController.TAG_IMAGES]
        if images != nil {
            if (images as! [UIImage]).count == 0 {
                PopupProvider.showInformPopup(with: UIImage(named: "sadscreen")!, "Informations manquantes", "il faut une image minimum", "ok", {print("action")})
                return false
            }
        } else {
            PopupProvider.showInformPopup(with: UIImage(named: "sadscreen")!, "Informations manquantes", "il faut une image minimum", "ok", {print("action")})
            return false
        }
        
        // ============
        // Record part
        
        me?.pictures_images = images as! [UIImage]
        // Here i can retrieve and downcast
        if let female = formValues[ParametersViewController.TAG_I_WANT_FEMALE] as! Bool?, let male = formValues[ParametersViewController.TAG_I_WANT_MALE] as! Bool? {
            me?.sexualOrientation = (female ? 2 : 0) + (male ? 1 : 0)
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
        // Optional upload Part
        
        return true
    }
    
    // Nice and fast way to customize the header view
    func tableView(_: UITableView, willDisplayHeaderView view: UIView, forSection: Int) {
        
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.textColor = .hoopRedColor
            view.textLabel?.font = .MainFontMedium(ofSize: 15.0)
            view.textLabel?.text = view.textLabel?.text?.lowercased()
        }
    }


}




