//
//  UINavigationController+replaceRoot.swift
//  hoop
//
//  Created by Clément on 02/01/2019.
//  Copyright © 2019 hoop. All rights reserved.
//

import UIKit

extension UINavigationController {
    /**
     It removes all view controllers from navigation controller then set the new root view controller and it pops.
     
     - parameter vc: root view controller to set a new
     */
    func replaceRootViewControllerBy(vc: UIViewController, transitionType type: CATransitionType = .fade, duration: CFTimeInterval = 0.3) {
        self.addTransition(transitionType: type, duration: duration)
        self.viewControllers.removeAll()
        self.pushViewController(vc, animated: false)
        self.popToRootViewController(animated: false)
    }
    
    /**
     It adds the animation of navigation flow.
     
     - parameter type: kCATransitionType, it means style of animation
     - parameter duration: CFTimeInterval, duration of animation
     */
    private func addTransition(transitionType type: CATransitionType = .fade, duration: CFTimeInterval = 0.3) {
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = type
        self.view.layer.add(transition, forKey: nil)
    }
}
