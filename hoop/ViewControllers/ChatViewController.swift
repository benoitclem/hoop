//
//  ChatViewController.swift
//  hoop
//
//  Created by Clément on 19/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit

class LeftConversationTableViewCell: UITableViewCell {
    @IBOutlet weak var BubbleView: UIView!
    @IBOutlet weak var TextLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    
}

class RightConversationTableViewCell: UITableViewCell {
    @IBOutlet weak var BubbleView: UIView!
    @IBOutlet weak var TextLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var RetryButton: UIButton!
    @IBOutlet weak var RetryWidthButtonConstraint: NSLayoutConstraint!
}

class ChatViewController: UIViewController {
    
    @IBOutlet weak var messageTableView: UITableView!
    
    var alreadyScrolledForKB = false
    
    var inputTextBar: InputTextFieldBar!
    var heightAtIndexPath = NSMutableDictionary()
    var mm: messageManager!
    var me: profile?
    
    @objc var profileId: String!
    
    var storageKey: String {
        get {
            return "storageKey\(String(describing: profileId))"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Retrive me coz we gonna need it
        me = AppDelegate.me
        
        // Create message manager for this specific user if does not exists
        mm = messageManager.get(withKey: storageKey)
        if mm == nil {
            mm = messageManager()
            mm.keyString = Key<messageManager>(storageKey)
            mm.save()
        }
        
        // Setup interface
        self.setupHoopNavigationBar("Chat",
                                    leftTitle: "Retour", leftSelector: #selector(ChatViewController.endViewController(sender:)),
                                    rightTitle: nil, rightSelector: nil)
        
        // Deal by ourselves the inset due to navigationbar
        messageTableView.contentInsetAdjustmentBehavior = .never
        messageTableView.contentInset.bottom = 60.0
        
        // Congfigure Inset
        // ???? IS THIE REALLY OK FOR CROSS DEVICE
        messageTableView.contentInset.top = 51.5
        messageTableView.scrollIndicatorInsets.top =  51.5
        
        
        // Configure message Taleview
        messageTableView.keyboardDismissMode = .interactive
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 50.0
        
        messageTableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi));
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardDidChangeFrame(_:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        
        update()
    }
    
    override func viewDidAppear(_ animated: Bool) {
       messageTableView.scrollIndicatorInsets.right = messageTableView.frame.width - 8.5
    }
    
    @objc func endViewController( sender: UIBarButtonItem) {
        // Will need to record stuffs here
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func sendMessageAction(_ sender: UIButton) {
        sendMessage()
    }
    
    
    // ========= Input bar stuffs =========
    
    lazy var inputContainerView: UIView = {
        // TODO: Here we could detect iphone X and set a soft safe area (pushing x to 20 reduce width by 40)
        inputTextBar = InputTextFieldBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 48.0))
        inputTextBar.SendButton.isEnabled = false
        inputTextBar.SendButton.addTarget(self, action: #selector(ChatViewController.sendMessageAction(_:)), for: .touchUpInside)
        inputTextBar.TextView.delegate = self
        inputTextBar.TextView.text = ""
        inputTextBar.PlaceHolderLabel.text = "message"
        //self.inputTextBar.trailingAnchor.constraint(equalTo:self.view.trailingAnchor).isActive = true
        return inputTextBar
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) {
            return true
        }
        return false
        //return [super canPerformAction:action withSender:sender];
    }
    
    override func paste(_ sender: Any?) {
        //        print(sender)
    }
    
    func cleanInputBox() {
        // Clean out the view
        inputTextBar.TextView.text = ""
        inputTextBar.SendButton.isEnabled = false
        inputTextBar.PlaceHolderLabel.isHidden = false
        inputTextBar.invalidateIntrinsicContentSize()
    }
    
    // tableview utils
    
    func scrollToBottom(_ animated: Bool = true) {
        if(mm.messages.count != 0){
            messageTableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: animated)
        }
    }

}

// Network calls
extension ChatViewController {
    
    // Need to be more specific with local id
    func update() {
        HoopNetworkApi.sharedInstance.getMessages(with: profileId).whenFulfilled(on: .main) { messages in
            let mods = self.mm.update(with: messages)
            self.mm.save()
            if !mods.toInsert.isEmpty || !mods.toUpdate.isEmpty {
                self.messageTableView.beginUpdates()
                self.messageTableView.reloadRows(at: mods.toUpdate, with: .none)
                self.messageTableView.insertRows(at: mods.toInsert, with:.top)
                self.messageTableView.endUpdates()
            }
        }
    }

    func sendMessage() {
        if let content = self.inputTextBar.TextView.text, let pid = profileId, let did = Int(pid) {
            let m = message(with: content, and: did)
            if let p = HoopNetworkApi.sharedInstance.postMessage(m) {
                p.whenFulfilled(on: .main) { _ in
                    self.update()
                }
            }
            mm?.messages.append(m)
            mm?.save()
            messageTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
            cleanInputBox()
        }
    }
    
}

extension ChatViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mm.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell

        let msg = mm.messages[mm.messages.count-1-indexPath.row]
        if (msg.dstId == me?.id) {
            cell = tableView.dequeueReusableCell(withIdentifier: "LeftConversationCell", for: indexPath)
            let v = cell as! LeftConversationTableViewCell
            v.TextLabel.text = msg.content
            v.BubbleView.layer.cornerRadius = 15
            if let date = msg.dateSent {
                if(NSCalendar.current.compare(date, to: Date.init(), toGranularity: .day) == ComparisonResult.orderedSame) {
                    v.DateLabel.text = DateFormatter.HHmm.string(from: date)
                } else {
                    v.DateLabel.text = DateFormatter.ddMMyy.string(from: date)
                }
            } else {
                v.DateLabel.text = ""
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "RightConversationCell", for: indexPath)
            let v = cell as! RightConversationTableViewCell
            v.TextLabel.text = msg.content
            v.BubbleView.layer.cornerRadius = 15
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.init(secondsFromGMT: 0)
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            v.RetryButton.layer.cornerRadius = 21.0/2
            v.RetryButton.layer.borderColor = UIColor.hoopRedColor.cgColor
            v.RetryButton.layer.borderWidth = 1.5
            v.RetryButton.tag = indexPath.row
            //v.RetryButton.addTarget(self, action: #selector(ChatViewController.retryAction), for: .touchUpInside)
            v.RetryWidthButtonConstraint.constant = 0.0
            if let date = msg.dateSent {
                if(NSCalendar.current.compare(date, to: Date.init(), toGranularity: .day) == ComparisonResult.orderedSame) {
                    v.DateLabel.text = DateFormatter.HHmm.string(from: date)
                } else {
                    v.DateLabel.text = DateFormatter.ddMMyy.string(from: date)
                }
            } else {
                v.DateLabel.text = ""
            }
        }
        // Reverse cell
        cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let height = NSNumber(value: Float(cell.frame.size.height))
        self.heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)
    }
}

extension ChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = self.heightAtIndexPath.object(forKey: indexPath) as? NSNumber {
            return CGFloat(height.floatValue)
        } else {
            return UITableView.automaticDimension
        }
    }
}

extension ChatViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        //self.inputTextBar.invalidateIntrinsicContentSize()
        if(inputTextBar.TextView.text.count == 0) {
            //self.SendButton.alpha = 0.4
            inputTextBar.SendButton.isEnabled = false
        } else {
            //self.SendButton.alpha = 1.0
            // When constraint is null it means that we are offline, so do not reactivate button
            inputTextBar.SendButton.isEnabled = true
        }
        inputTextBar.PlaceHolderLabel.isHidden = inputTextBar.TextView.text.count > 0
    }
    
    @objc func keyboardDidChangeFrame(_ notification:Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            NSLog("keyboard %f",keyboardSize.height)
            let currentKeyboardSize = keyboardSize.height
            if(true) {
                //if(currentKeyboardSize > 100.0) {
                // Resize the all view, constraint will
                let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
                //self.ConvTableToBottomConstraint.constant = self.currentKeyboardSize
                // Would be cool if we could animate the inset insertion
                messageTableView.contentInset.top = currentKeyboardSize
                messageTableView.scrollIndicatorInsets.top = currentKeyboardSize
                // Put the scroll bar to the right
                //self.tableView.contentInset.bottom = self.currentKeyboardSize
                //self.tableView.scrollIndicatorInsets.bottom = self.currentKeyboardSize
                UIView.animate(withDuration: duration, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { _ in
                    if(!self.alreadyScrolledForKB) {
                        self.alreadyScrolledForKB = true
                        self.scrollToBottom(false)
                    }
                    if(currentKeyboardSize>60) {
                        self.scrollToBottom()
                    }
                    
                    // if Keyboard is deployed, we want to write
                    
                })
            }
        }
    }
}
