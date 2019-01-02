//
//  UIViewController+customNavigationBar.swift
//  hoop
//
//  Created by Clément on 02/01/2019.
//  Copyright © 2019 hoop. All rights reserved.
//

import UIKit

extension UIViewController {
    func setupHoopNavigationBar(_ title: String,
                leftTitle lTitle:String?, leftSelector lSelector: Selector?,
                rightTitle rTitle:String?, rightSelector rSelector: Selector?) {
        self.title = title
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.hoopRedColor,
             NSAttributedString.Key.font: UIFont.MainFontMedium(ofSize: 28.0)]
        if let title = rTitle {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: rSelector)
            self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.hoopRedColor,
                                                                            NSAttributedString.Key.font: UIFont.MainFontMedium(ofSize: 15.0)], for: .normal)
        }
        if let title = lTitle {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: lSelector)
            self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.hoopRedColor,
                                                                            NSAttributedString.Key.font: UIFont.MainFontMedium(ofSize: 15.0)], for: .normal)
        }
    }
}
