//
//  UIViewController+customNavigationBar.swift
//  hoop
//
//  Created by Clément on 02/01/2019.
//  Copyright © 2019 hoop. All rights reserved.
//

import UIKit

extension UIViewController {
    func addNavigationBar(_ title: String, 
                leftTitle lTitle:String, rightTitle rTitle:String, 
                leftClosure lClosure: @escaping (()->()), rightClosure rClosure: @escaping ()->()) {
        
        let leftButtonView = UIView.init(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        
        let leftButton = UIButton.init(type: .system)
        leftButton.backgroundColor = .clear
        leftButton.frame = leftButtonView.frame
        leftButton.setTitle("lTitle", for: .normal)
        //leftButton.tintColor = .red
        leftButton.titleLabel?.backgroundColor = .red
        //leftButton.titleLabel?.font =  .MainFontLight(ofSize: 14.0)
        leftButton.autoresizesSubviews = true
        leftButton.autoresizingMask = [.flexibleWidth , .flexibleHeight]
        leftButton.addAction(for: .touchUpInside, lClosure)
        leftButtonView.addSubview(leftButton)

        let leftBarButton = UIBarButtonItem.init(customView: leftButtonView)

        let rightButtonView = UIView.init(frame: CGRect(x: 0, y: 0, width: 150, height: 50))

        let rightButton = UIButton.init(type: .system)
        rightButton.backgroundColor = .clear
        rightButton.frame = rightButtonView.frame
        rightButton.setTitle("rTitle", for: .normal)
        //rightButton.tintColor = .red
        rightButton.titleLabel?.backgroundColor = .red
        //rightButton.titleLabel?.font =  .MainFontLight(ofSize: 14.0)
        rightButton.autoresizesSubviews = true
        rightButton.autoresizingMask = [.flexibleWidth , .flexibleHeight]
        rightButton.addAction(for: .touchUpInside, rClosure)
        rightButtonView.addSubview(leftButton)

        let rightBarButton = UIBarButtonItem.init(customView: leftButtonView)
//
        let standaloneItem = UINavigationItem()
        standaloneItem.rightBarButtonItem = leftBarButton
        //standaloneItem.backBarButtonItem = rightBarButton
        
        let titlelabel = UILabel()
        titlelabel.text = title
        titlelabel.textColor = UIColor.hoopRedColor
        titlelabel.font = UIFont.MainFontMedium(ofSize: 17.0)
        standaloneItem.titleView = titlelabel
        
        let navigationBar = UINavigationBar()
        navigationBar.isTranslucent = false
        navigationBar.delegate = self as? UINavigationBarDelegate
        navigationBar.backgroundColor = .white
        navigationBar.items = [standaloneItem]
        
        view.addSubview(navigationBar)
        
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        if #available(iOS 11, *) {
            navigationBar.topAnchor.constraint(equalTo:
                view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        }
        
        let maskView = UIView()
        maskView.backgroundColor = .white
        
        view.addSubview(maskView)
        
        maskView.translatesAutoresizingMaskIntoConstraints = false
        maskView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        maskView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        maskView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        maskView.bottomAnchor.constraint(equalTo: navigationBar.topAnchor).isActive = true
        
    }
}
