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
        
        // [SECTION] Pictures photo
        form +++ Section("Mes photos")
            <<< ImageCollectionViewRow() { row in
                row.tag = "images"
                row.value = [UIImage]()
                row.value?.append(UIImage(named: "sophie")!)
                row.value?.append(UIImage(named: "sophie")!)
                row.value?.append(UIImage(named: "sophie")!)
            }
        
        
        // [SECTION] Prénom Age
//        me?.name = nil // Testing stuff
//        me?.dob = nil  // Testing stuff
//        me?.gender = nil
        
        var nameRowEditable: HoopTextViewRow? = nil
        var nameRow: HoopLabelRow? = nil
        if let name = me?.name {
            nameRow = HoopLabelRow() { row in
                row.title = name
            }
        } else {
            nameRowEditable = HoopTextViewRow() { row in
                row.tag = "name"
                row.value = ""
                row.placeholder = "nom"
            }
        }
        
        var dobRowEditable: HoopDateRow? = nil
        var ageRow: HoopLabelRow? = nil
        if let age = me?.age {
            ageRow = HoopLabelRow() { row in
                row.title = String(age)
            }
        } else {
            dobRowEditable = HoopDateRow() { row in
                row.labelText = "Date de naissance"
                row.dateFormatter = DateFormatter.ddMMMyyyy
                let calendar: NSCalendar! = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
                row.maximumDate = calendar.date(byAdding: .year, value: -18, to: Date.init())
            }
        }
        
        form +++ Section("Informations")
            <<< (nameRow ?? nameRowEditable!)
            <<< (ageRow ?? dobRowEditable!)
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
        
        form +++ Section("Vous êtes") { section in
                section.hidden = Condition.function([], { _ in
                    return self.me?.gender != nil
                })
            }
            <<< HoopSwitchRow() { row in
                row.tag = "switchFemme"
                row.labelText = "Femme"
                row.value = false
            }
            <<< HoopSwitchRow() { row in
                row.tag = "switchFemme"
                row.labelText = "Femme"
                row.value = true
            }.onChange { _ in
                print("something happened")
            }
        
//        form +++ SelectableSection<ListCheckRow<String>>("Vous êtes", selectionType: .singleSelection(enableDeselection: false))
//
//        let continents = ["homme", "femme"]
//        for option in continents {
//            form.last! <<< ListCheckRow<String>(option){ listRow in
//                listRow.title = option
//                listRow.selectableValue = option
//                listRow.value = nil
//            }
//        }
        
        // [SECTION] Je souhaite rencontrer
        form +++ Section("Je souhaite rencontrer")
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
            view.textLabel?.textColor = .red
            view.textLabel?.font = UIFont.MainFontMedium(ofSize: 15.0)
        }
    }

}




