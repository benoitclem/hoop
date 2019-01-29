//
//  ConversationViewController.swift
//  hoop
//
//  Created by Clément on 19/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit
import Kingfisher


class ConversationViewCell: UITableViewCell{
    @IBOutlet weak var unreadIndicatorView: UIView!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileLastMessageLabel: UILabel!
    @IBOutlet weak var profileLastMessageTimeLabel: UILabel!
}


class ConversationViewController: NotifiableUIViewController {

    @IBOutlet weak var conversationTableView: UITableView!
    
    var me: profile? = AppDelegate.me
    var cm: conversationManager! = conversationManager.get()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.conversationTableView.estimatedRowHeight = 44.0
        self.conversationTableView.rowHeight = UITableView.automaticDimension
        
        // If conversationManager does not exist create & save it
        if cm == nil {
            cm = conversationManager()
            cm.save()
        }
        
        // Setup interface
        self.setupHoopNavigationBar("Conversations",
                                    leftTitle: "Retour", leftSelector: #selector(ConversationViewController.endViewController(sender:)),
                                    rightTitle: nil, rightSelector: nil)

    }
    
    @objc override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // request remaining converstaions
        update()
    }
    
    @objc override func viewDidEnterForeground(notification: Notification) {
        super.viewDidEnterForeground(notification: notification)
        update()
    }
    
    @objc func endViewController( sender: UIBarButtonItem) {
        // Will need to record stuffs here
        self.navigationController?.popViewController(animated: true)
    }
    
    func update() {
        // Get remaining conversation for boyzzzz
        if me?.gender == 1 {
            HoopNetworkApi.sharedInstance.getRemainingConversations().whenFulfilled(on: .main) { nConvs in
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "\(nConvs)", style: .done, target: self, action: nil)
                self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.hoopRedColor, NSAttributedString.Key.font: UIFont.MainFontMedium(ofSize: 15.0)], for: .normal)
            }
        }
        
        // request new modifications
        HoopNetworkApi.sharedInstance.getAllConversations().whenFulfilled(on: .main) { convs in
            print(convs)
            if let cm = self.cm {
                if cm.update(withConversations: convs) {
                    self.conversationTableView.reloadData()
                }
                cm.save()
            }
        }
            
    }
    
    override func didReceiveNotification(notification: Notification) {
        print("Conv View Did receive notif")
        let nData = notification.object as! notificationData
        update()
    }

}

extension ConversationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            if let thConv = cm?.th_conversations {
                return thConv.count != 0 ? thConv.count : 1
            } else {
                return 1
            }
        } else {
            if let conv = cm?.conversations {
                return conv.count
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var c = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationViewCell
        if indexPath.section == 0 {
            if let thConvs = cm?.th_conversations {
                if thConvs.count != 0 {
                    fillCell(withConversation: thConvs[indexPath.row], and: &c)
                } else if let conv = cm?.user_th_conversation {
                    fillCell(withConversation: conv, and: &c)
                }
            }
            // Go look into the th conv
        } else {
            let index = indexPath.row
            if let conv = cm?.conversations[index] {
                fillCell(withConversation: conv, and: &c)
            } 
        }
        return c
    }
    
    func fillCell(withConversation conv:conversation, and cell: inout ConversationViewCell) {
        // unread indicator
        if (conv.expId != me?.id) && (conv.dateRead == nil) {
            cell.unreadIndicatorView.isHidden = false
            cell.unreadIndicatorView.backgroundColor = UIColor.hoopGreenColor
        } else {
            cell.unreadIndicatorView.isHidden = true
        }
        // profile image
        if let profUrl = conv.profilePictureUrl {
            cell.profilePictureImageView.kf.setImage(with: profUrl)
        }
        // text Content
        cell.profileNameLabel.text = conv.nickname ?? "unknwon"
        cell.profileLastMessageLabel.text = conv.lastMessage ?? "-"
        cell.profileLastMessageTimeLabel.text = conv.when
    }
}

extension ConversationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // visually deselect the row
        conversationTableView.deselectRow(at: indexPath, animated: true)
        // Now segue to the right view
        if indexPath.section == 0 {
            let conv = cm.conversations[indexPath.row]
            if let vc = try? Router.shared.matchControllerFromStoryboard("/chat/1",storyboardName: "Main") {
                self.navigationController?.pushViewController(vc as! UIViewController, animated: true)
            }
        } else {
            let conv = cm.conversations[indexPath.row]
            if let vc = try? Router.shared.matchControllerFromStoryboard("/chat/\(conv.finalExpId)",storyboardName: "Main") {
                self.navigationController?.pushViewController(vc as! UIViewController, animated: true)
            }
        }
    }
    
}
