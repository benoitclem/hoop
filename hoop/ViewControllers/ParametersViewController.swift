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
        
        // [SECTION] Pictures photo
        form +++ Section("Mes photos")
            <<< ImageCollectionViewRow() { row in
                row.tag = "images"
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
                    return self.me?.name != nil
                })
                if let name = self.me?.name {
                    row.title = name
                }
            }
            <<< HoopTextViewRow() { row in
                row.hidden = Condition.function([], { _ in
                    return self.me?.name == nil
                })
                row.tag = "name"
                row.content = ""
                row.placeholder = "nom"
            }
            <<< HoopLabelRow() { row in
                row.hidden = Condition.function([], { _ in
                    return self.me?.age != nil
                })
                if let age = self.me?.age {
                    row.title = String(age)
                }
            }
            <<< HoopDateRow() { row in
                row.hidden = Condition.function([], { _ in
                    return self.me?.age == nil
                })
                row.labelText = "Date de naissance"
                row.dateFormatter = DateFormatter.ddMMMyyyy
                let calendar: NSCalendar! = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
                row.maximumDate = calendar.date(byAdding: .year, value: -18, to: Date.init())
            }
            <<< EmailRow() { row in
                    row.tag = "email"
                    row.hidden = Condition.function([], { _ in
                            return self.me?.email != nil
                        })
                    row.title = "email"
                }

        // [SECTION] A propos de moi
        form +++ Section("À propos de moi")
            <<< HoopTextViewRow() { row in
                row.tag = "description"
                row.value = ""
                row.placeholder = "write something here"
            }
        
        // [SECTION] Je suis
        if let gender = self.me?.gender{
            form +++ SelectableSection<HoopListCheckRow>("Je suis", selectionType: .singleSelection(enableDeselection: false))
                <<< HoopListCheckRow() { row in
                    row.tag = "iAmMale"
                    row.labelText = "Homme"
                    row.selectableValue = false
                    row.value = nil
                }
                <<< HoopListCheckRow() { row in
                    row.tag = "iAmFemale"
                    row.labelText = "Femme"
                    row.selectableValue = false
                    row.value = nil
                }
        }
        
        // [SECTION] Je souhaite rencontrer
        form +++ Section("Je souhaite rencontrer, Je souhaite rencontrer, Je souhaite rencontrer, Je souhaite rencontrer, Je souhaite rencontrer,")
            <<< SwitchRow() { row in
                row.tag = "switchHomme"
                row.title = "Homme"
            }
            <<< HoopSwitchRow() { row in
                row.tag = "switchFemme"
                row.labelText = "Femme"
                row.value = true
            }
            <<< HoopRangeRow() { row in
                row.tag = "ageRange"
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
        if let vc = try? Router.shared.matchControllerFromStoryboard("/map", storyboardName: "Main") {
            self.navigationController?.replaceRootViewControllerBy(vc: vc as! MapViewController)
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

}




