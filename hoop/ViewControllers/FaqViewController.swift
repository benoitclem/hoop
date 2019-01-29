//
//  FaqViewController.swift
//  hoop
//
//  Created by Clément on 19/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit
import Eureka

class FaqViewController: NotifiableFormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupToolbar()

        self.tableView.backgroundColor = .hoopTableGrayColor
        self.tableView.separatorStyle = .none
        

        let promise = HoopNetworkApi.sharedInstance.getFaq()
        promise?.whenFulfilled(on: .main){ (faqEntries) in
            for entry in faqEntries {
                self.form +++ Section(entry.name ?? "")
                    <<< HoopTextViewRow() { row in
                        row.content = entry.content ?? ""
                }
            
            }
        }
    }
    
    func setupToolbar() {
        let vcTitle = "faq_vc_title".localized()
        var leftTitle: String? = "back".localized()
        var leftSelector: Selector? = #selector(FaqViewController.leftTarget(sender:))
        let rightTitle: String? = nil
        let rightSelector: Selector? = nil
        
        self.setupHoopNavigationBar(vcTitle,
                                    leftTitle: leftTitle, leftSelector: leftSelector,
                                    rightTitle: rightTitle, rightSelector: rightSelector)
    }
    
    @objc func leftTarget( sender: UIBarButtonItem) {
        print("cancel")
        self.navigationController?.popViewController(animated: true)
    }
    
    // Nice and fast way to customize the header view
    func tableView(_: UITableView, willDisplayHeaderView view: UIView, forSection: Int) {
        
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.textColor = .hoopRedColor
            view.textLabel?.font = .MainFontMedium(ofSize: 15.0)
            view.textLabel?.text = view.textLabel?.text?.lowercased()
        }
    }
    
    override func didReceiveNotification(notification: Notification) {
        print("FAQ View Did receive notif")
        let nData = notification.object as! notificationData
        PopupProvider.showMessageToast(with: nData, tapAction: { profileId in
            self.jumpToProfile(withId: profileId)
        })
    }
    
    func jumpToProfile(withId profileId: Int){
        if let chatVC = try? Router.shared.matchControllerFromStoryboard("/chat/\(profileId)",storyboardName: "Main") as! UIViewController,
            let convVC = try? Router.shared.matchControllerFromStoryboard("/conversations",storyboardName: "Main") as! UIViewController {
            if var vcs = self.navigationController?.viewControllers {
                let _ = vcs.popLast() // pop the FAQ VC
                let _ = vcs.popLast() // pop the Parameters VC
                vcs.append(convVC)
                vcs.append(chatVC)
                self.navigationController?.setViewControllers(vcs, animated: true)
            }
        }
    }
}
