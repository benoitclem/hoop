//
//  InfoTunnelViewController.swift
//  hoop
//
//  Created by Clément on 19/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit
import Eureka

class InfoTunnelViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do re
        // Color of the background table
        self.tableView.backgroundColor = UIColor.white
        form +++ Section("Nom")
            <<< HoopTextViewRow() { row in
                row.tag = "nom"
                row.value = ""
                row.placeholder = "nom"
            }
            +++ Section("Age")
            <<< DateRow(){
                $0.title = "Date Row"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)
            }
            +++ Section("Je suis")
            <<< HoopSwitchRow() { row in
                row.tag = "switchFemme"
                row.labelText = "Un homme / une femme"
                row.value = true
            }
            +++ Section("Email")
            <<< HoopTextViewRow() { row in
                row.tag = "email"
                row.value = ""
                row.placeholder = "email"
            }
    }
}
