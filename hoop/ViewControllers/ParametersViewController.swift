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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNavigationBar("parameters", leftTitle: "back", rightTitle: "terminer", leftClosure: {
            print("do L something")
        }, rightClosure: {
            print("do R something")
        })
        self.tableView.contentInset = UIEdgeInsets(top: 44.0, left: 0, bottom: 0, right: 0)
        // Color of the background table
        self.tableView.backgroundColor = UIColor.white
        form +++ Section("Mes photos")
            <<< ImageCollectionViewRow() { row in
                row.tag = "images"
                row.value = [UIImage]()
                row.value?.append(UIImage(named: "sophie")!)
                row.value?.append(UIImage(named: "sophie")!)
                row.value?.append(UIImage(named: "sophie")!)
            }
            +++ Section("Informations")
            <<< HoopLabelRow() { row in
                row.title = "clément"
            }
            <<< HoopLabelRow() { row in
                var style = HoopLabelRowStyle()
                style.bgColor = UIColor.green
                style.txtColor = UIColor.white
                row.labelText = "31"
                row.value = "salut"
                row.labelStyle = style
            }
            +++ Section("À propos de moi")
            <<< HoopTextViewRow() { row in
                row.tag = "description"
                row.value = ""
                row.placeholder = "write something here"
            }
            +++ Section("Je souhaite rencontrer")
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
            <<< PhoneRow(){
                $0.title = "Phone Row"
                $0.placeholder = "And numbers here"
            }
            +++ Section("Section2")
            <<< DateRow(){
                $0.title = "Date Row"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)
            }
            <<< HoopLabelRow() { row in
                var style = HoopLabelRowStyle()
                style.bgColor = UIColor.green
                style.txtColor = UIColor.white
                style.txtAlignement = NSTextAlignment.center
                row.labelText = "salut"
                row.labelStyle = style
                }.onCellSelection { cell, row in
                    //row.title = "action 1"
                    print(self.form.values())
        }
        
    }
    
    // Nice and fast way to customize the header view
    func tableView(_: UITableView, willDisplayHeaderView view: UIView, forSection: Int) {
        
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.textColor = .red
            view.textLabel?.font = UIFont.MainFontMedium(ofSize: 15.0)
        }
    }
    
    @IBAction func getFormInfos(_ sender: Any) {
    }
}




