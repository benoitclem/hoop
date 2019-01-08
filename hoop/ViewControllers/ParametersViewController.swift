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
    static let TAG_NAME = "me_name"
    static let TAG_NAME_EDIT = "me_name_edit"
    static let TAG_AGE = "me_age"
    static let TAG_AGE_EDIT = "me_age_edit"
    static let TAG_EMAIL_EDIT = "me_email_edit"
    static let TAG_DESCRIPTION = "me_description"
    static let TAG_I_AM_MALE = "me_iAmMale"
    static let TAG_I_AM_FEMALE = "me_iAmFemale"
    static let TAG_I_WANT_MALE = "me_iWantMale"
    static let TAG_I_WANT_FEMALE = "me_iWantFemale"
    static let TAG_I_WANT_AGERANGE = "me_iWantAgeRange"
    
    let me: profile? = Defaults().get(for: .me)
    var firstTimer: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let reached_map = me?.reached_map {
            firstTimer = !reached_map
        }
        
        let vcTitle = "parameter_vc_title".localized()
        var leftTitle: String? = "back".localized()
        var leftSelector: Selector? = #selector(ParametersViewController.leftTarget(sender:))
        let rightTitle = "done".localized()
        let rightSelector = #selector(ParametersViewController.rightTarget(sender:))
        
        if (firstTimer) {
            leftTitle = nil
            leftSelector = nil
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
                row.tag = ParametersViewController.TAG_NAME
                row.hidden = Condition.function([], { _ in
                    return self.me?.name == nil
                })
                if let name = self.me?.name {
                    row.title = name
                }
            }
            <<< HoopTextViewRow() { row in
                row.tag = ParametersViewController.TAG_NAME_EDIT
                row.hidden = Condition.function([], { _ in
                    return self.me?.name != nil
                })
                row.content = ""
                row.placeholder = "nom"
            }
            <<< HoopLabelRow() { row in
                row.tag = ParametersViewController.TAG_AGE
                row.hidden = Condition.function([], { _ in
                    return self.me?.age == nil
                })
                if let age = self.me?.age {
                    row.title = String(age)
                }
            }
            <<< HoopDateRow() { row in
                row.tag = ParametersViewController.TAG_AGE_EDIT
                row.hidden = Condition.function([], { _ in
                    return self.me?.age != nil
                })
                row.labelText = "Date de naissance"
                row.dateFormatter = DateFormatter.ddMMMyyyy
                let calendar: NSCalendar! = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
                row.maximumDate = calendar.date(byAdding: .year, value: -18, to: Date.init())
            }
            <<< EmailRow() { row in
                row.tag = ParametersViewController.TAG_EMAIL_EDIT
                row.add(ruleSet:emailRules)
                row.hidden = Condition.function([], { _ in
                    return self.me?.email != nil
                })
                row.title = "email"
            }

        // [SECTION] A propos de moi
        form +++ Section("À propos de moi")
            <<< HoopTextViewRow() { row in
                row.tag = ParametersViewController.TAG_DESCRIPTION
                row.value = ""
                row.placeholder = "write something here"
            }
        
        // [SECTION] Je suis
        var iAmMaleVal:Bool? = nil
        var iAmFemaleVal:Bool? = nil
        if let gender = self.me?.gender{
            iAmMaleVal = gender == 1
            iAmFemaleVal = gender == 2
        }

        form +++ SelectableSection<HoopListCheckRow>("Je suis", selectionType: .singleSelection(enableDeselection: false))
            <<< HoopListCheckRow() { row in
                row.tag = ParametersViewController.TAG_I_AM_MALE
                row.labelText = "Homme"
                row.selectableValue = false
                row.value = iAmMaleVal
            }
            <<< HoopListCheckRow() { row in
                row.tag = ParametersViewController.TAG_I_AM_FEMALE
                row.labelText = "Femme"
                row.selectableValue = false
                row.value = iAmFemaleVal
            }
        
        // [SECTION] Je souhaite rencontrer
        form +++ Section("Je souhaite rencontrer, Je souhaite rencontrer, Je souhaite rencontrer, Je souhaite rencontrer, Je souhaite rencontrer,")
            <<< SwitchRow() { row in
                row.tag = ParametersViewController.TAG_I_WANT_MALE
                row.title = "Homme"
            }
            <<< HoopSwitchRow() { row in
                row.tag = ParametersViewController.TAG_I_WANT_FEMALE
                row.labelText = "Femme"
                row.value = true
            }
            <<< HoopRangeRow() { row in
                row.tag = ParametersViewController.TAG_I_WANT_AGERANGE
                row.labelText = "Tranche d'age"
                row.value = Range(min: 18,low: 18,upp: 55,max: 55)
            }
            
        if (firstTimer) {
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
        if let vc = try? Router.shared.matchControllerFromStoryboard("/map", storyboardName: "Main") {
            self.navigationController?.replaceRootViewControllerBy(vc: vc as! MapViewController)
        }
    }
    
    @objc func rightTarget( sender: UIBarButtonItem) {
        print("done")

        if(true) {
        //if (validateAndSave()) {
            if let vc = try? Router.shared.matchControllerFromStoryboard("/map", storyboardName: "Main") {
                self.navigationController?.replaceRootViewControllerBy(vc: vc as! MapViewController)
            }
        }

        /*
        */
    }
    
    func validateAndSave() -> Bool {
        let formValues = form.values()
        // print(formValues)
        
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
        
        let name = self.me?.name
        let name_edit = formValues[ParametersViewController.TAG_NAME_EDIT] as! String?
        if (name == nil) && (name_edit == nil) {
            PopupProvider.showInformPopup(with: UIImage(named: "sadscreen")!, "Informations manquantes", "Veuillez remplir votre nom", "ok", {print("action")})
            return false
        }
        
        let age = self.me?.age
        let age_edit = formValues[ParametersViewController.TAG_AGE_EDIT] as! Date?
        if (age == nil) && (age_edit == nil) {
            //
            PopupProvider.showInformPopup(with: UIImage(named: "sadscreen")!, "Informations manquantes", "Veuillez remplir votre age", "ok", {print("action")})
            return false
        }
        
        let email = self.me?.email
        let email_edit = formValues[ParametersViewController.TAG_EMAIL_EDIT] as! String?
        if (email == nil) && (email_edit == nil) {
            PopupProvider.showInformPopup(with: UIImage(named: "sadscreen")!, "Informations manquantes", "Veuillez remplir votre email", "ok", {print("action")})
            return false
        }
        
        let gender = self.me?.gender
        let iAmMale = formValues[ParametersViewController.TAG_I_AM_MALE]
        let iAmFemale = formValues[ParametersViewController.TAG_I_AM_FEMALE]
        if (gender == nil) && (iAmMale == nil) && (iAmFemale == nil) {
            PopupProvider.showInformPopup(with: UIImage(named: "sadscreen")!, "Informations manquantes", "Veuillez remplir votre sexe", "ok", {print("action")})
            return false
        }
        
        
        // Record part
        me?.pictures_images = images as! [UIImage]
        
        if name == nil {
            me?.name = name_edit
        }
        
        if age == nil {
            me?.dob = age_edit
        }
        
        if email == nil {
            me?.email = email_edit
        }
        
        if gender == nil {
        }
        
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




