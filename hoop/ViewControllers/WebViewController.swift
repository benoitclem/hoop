//
//  WebViewController.swift
//  hoop
//
//  Created by Clément on 19/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    @IBOutlet weak var webview: WKWebView!
    
    @objc var target: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupToolbar(self.target ?? "web")
        
        let promise = HoopNetworkApi.sharedInstance.getConditions()
        promise?.whenFulfilled(on: .main){ (conditions) in
            if let condition = conditions.first(where: { $0.name == self.target }) {
                self.webview.loadHTMLString(condition.content ?? "<h1>404 error<h2>", baseURL: nil)
            }
        }
    }
    
    func setupToolbar(_ title: String) {
        let vcTitle = title
        let leftTitle: String? = "back".localized()
        let leftSelector: Selector? = #selector(WebViewController.leftTarget(sender:))
        
        self.setupHoopNavigationBar(vcTitle,
                                    leftTitle: leftTitle, leftSelector: leftSelector,
                                    rightTitle: nil, rightSelector: nil)
    }
    
    @objc func leftTarget( sender: UIBarButtonItem) {
        print("cancel")
        self.navigationController?.popViewController(animated: true)
    }
}
