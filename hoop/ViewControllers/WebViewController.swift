//
//  WebViewController.swift
//  hoop
//
//  Created by Clément on 19/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: NotifiableUIViewController {
    
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
    
    override func didReceiveNotification(notification: Notification) {
        print("Web View Did receive notif")
        let nData = notification.object as! notificationData
        PopupProvider.showMessageToast(with: nData, tapAction: { profileId in
            self.jumpToProfile(withId: profileId)
        })
    }
    
    func jumpToProfile(withId profileId: Int){
        if let chatVC = try? Router.shared.matchControllerFromStoryboard("/chat/\(profileId)",storyboardName: "Main") as! UIViewController,
            let convVC = try? Router.shared.matchControllerFromStoryboard("/conversations",storyboardName: "Main") as! UIViewController {
            if var vcs = self.navigationController?.viewControllers {
                let _ = vcs.popLast() // pop the Web VC
                let _ = vcs.popLast() // pop the Parameters VC
                vcs.append(convVC)
                vcs.append(chatVC)
                self.navigationController?.setViewControllers(vcs, animated: true)
            }
        }
    }
}
