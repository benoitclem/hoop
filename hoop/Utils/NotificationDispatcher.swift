//
//  NotificationDispatcher.swift
//  hoop
//
//  Created by Clément on 28/01/2019.
//  Copyright © 2019 hoop. All rights reserved.
//

import Foundation
import UIKit


extension Notification.Name {
    static let didReceiveNotification = Notification.Name("didReceiveNotification")
}

class NotifiableUIViewController : UIViewController {
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.viewDidEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.viewDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveNotification), name: .didReceiveNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .didReceiveNotification, object: nil)
    }
    
    @objc func viewDidEnterForeground(notification: Notification) {
        print("override me")
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveNotification), name: .didReceiveNotification, object: nil)
    }
    
    @objc func viewDidEnterBackground(notification: Notification) {
        print("override me")
        NotificationCenter.default.removeObserver(self, name: .didReceiveNotification, object: nil)
    }
    
    @objc func didReceiveNotification(notification: Notification) {
        print("override me")
    }
    
    static func postNotification(with data: [String: Any]) {
        NotificationCenter.default.post(name: .didReceiveNotification, object: data)
    }
    
}
