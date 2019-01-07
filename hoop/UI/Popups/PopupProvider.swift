//
//  PopupProvider.swift
//  hoop
//
//  Created by Clément on 20/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit
import SwiftEntryKit

class PopupProvider {
    
    static func showProcessingNote() {
        var attributes: EKAttributes
        
        // fill the attributes
        attributes = .topNote
        attributes.hapticFeedbackType = .none
        attributes.displayDuration = .infinity
        attributes.popBehavior = .animated(animation: .translation)
        attributes.entryBackground = .color(color: .blue)
        attributes.statusBar = .light
        
        // Fill up the Note message View
        let text = "Envoi en cours"
        let style = EKProperty.LabelStyle(font: UIFont.MainFontLight(ofSize: 12.0), color: .white, alignment: .center)
        let labelContent = EKProperty.LabelContent(text: text, style: style)
        
        let contentView = EKProcessingNoteMessageView(with: labelContent, activityIndicator: .white)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
    
    static func showDoneNote() {
        var attributes: EKAttributes
        
        // fill the attributes
        attributes = .topNote
        attributes.hapticFeedbackType = .success
        attributes.displayDuration = 2.0
        attributes.popBehavior = .animated(animation: .translation)
        attributes.entryBackground = .color(color: .green)
        attributes.statusBar = .light
        
        // Fill up the Note message View
        let text = "Envoi réussi"
        let style = EKProperty.LabelStyle(font:  UIFont.MainFontLight(ofSize: 12.0), color: .white, alignment: .center)
        let labelContent = EKProperty.LabelContent(text: text, style: style)
        
        let contentView = EKNoteMessageView(with: labelContent)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
    
    static func showErrorNote() {
        var attributes: EKAttributes
        
        // Fill the attribute structure
        attributes = .topNote
        attributes.hapticFeedbackType = .error
        attributes.displayDuration = .infinity
        attributes.popBehavior = .animated(animation: .translation)
        attributes.entryBackground = .color(color: .red)
        attributes.statusBar = .light
        
        // Fill up the Note message View
        let text = "Echec de l'envoi"
        let style = EKProperty.LabelStyle(font:  UIFont.MainFontLight(ofSize: 12.0), color: .white, alignment: .center)
        let labelContent = EKProperty.LabelContent(text: text, style: style)
        
        let contentView = EKNoteMessageView(with: labelContent)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
    
//    static func showFormPopup() {
//        var attributes: EKAttributes
//
//        attributes = .float
//        attributes.windowLevel = .normal
//        attributes.position = .center
//        attributes.displayDuration = .infinity
//
//        attributes.entranceAnimation = .init(translate: .init(duration: 0.65, anchorPosition: .bottom,  spring: .init(damping: 1, initialVelocity: 0)))
//        attributes.exitAnimation = .init(translate: .init(duration: 0.65, anchorPosition: .top, spring: .init(damping: 1, initialVelocity: 0)))
//        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.65, spring: .init(damping: 1, initialVelocity: 0))))
//
//        attributes.entryInteraction = .absorbTouches
//        attributes.screenInteraction = .dismiss
//
//        attributes.entryBackground = .color(color: .white)
//        attributes.screenBackground = .color(color: .gray)
//
//        attributes.border = .value(color: UIColor(white: 0.6, alpha: 1), width: 1)
//        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 3))
//        attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
//        attributes.statusBar = .light
//
//        let contentView = MessagePopupView(recipient: "Sophie 27", thumbString: "sophie", sendClosure: {
//            self.doProcessing((Any).self)
//        }, cancelClosure: nil)
//        SwiftEntryKit.display(entry: contentView, using: attributes, presentInsideKeyWindow: true)
//
//    }
    
    func showTwoChoicesPopup() {
        
    }
    
    static func showInformPopup(with image:UIImage,_ titleText: String,_ descriptionText: String,_ buttonText:String,_ buttonAction:@escaping (()->())) {
        var attributes: EKAttributes
        
        // Fill the attribute structure
        attributes = .centerFloat
        attributes.hapticFeedbackType = .success
        attributes.displayDuration = .infinity
        attributes.popBehavior = .animated(animation: .translation)
        attributes.entryBackground = .color(color: .red)
        attributes.statusBar = .light
        
        let image = EKProperty.ImageContent(image: image)
        let title = EKProperty.LabelContent(text: titleText, style: .init(font: UIFont.MainFontLight(ofSize: 15.0), color: .white, alignment: .center))
        let description = EKProperty.LabelContent(text: descriptionText, style: .init(font: UIFont.MainFontLight(ofSize: 12.0), color: .white))
        let buttonContent = EKProperty.LabelContent(text: buttonText, style: .init(font: UIFont.MainFontLight(ofSize: 12.0), color: .white))
        let button = EKProperty.ButtonContent(label: buttonContent, backgroundColor: .blue, highlightedBackgroundColor: .gray)
        let popupMessage = EKPopUpMessage(themeImage: EKPopUpMessage.ThemeImage.init(image: image), title: title, description: description, button: button, action: buttonAction)
        let contentView = EKPopUpMessageView(with: popupMessage)
        
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
    
    static func showMessageToast() {
        var attributes: EKAttributes
        
        // Fill the attribute structure
        attributes = .topToast
        attributes.hapticFeedbackType = .success
        attributes.entryBackground = .color(color: .blue)
        attributes.entranceAnimation = .translation
        attributes.exitAnimation = .translation
        attributes.scroll = .edgeCrossingDisabled(swipeable: true)
        attributes.displayDuration = 4
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10))
        
        // Fill up the toast
        let title = EKProperty.LabelContent(text: "Sophie", style: .init(font: UIFont.MainFontLight(ofSize: 12.0), color: .white))
        let description = EKProperty.LabelContent(text: "Salut on va manger un 🍲 ce midi", style: .init(font: UIFont.MainFontLight(ofSize: 12.0), color: .white))
        let time = EKProperty.LabelContent(text: "09:00", style: .init(font:  UIFont.MainFontLight(ofSize: 12.0), color: .white))
        let image = EKProperty.ImageContent.thumb(with: "sophie", edgeSize: 35)
        let simpleMessage = EKSimpleMessage(image: image, title: title, description: description)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage, auxiliary: time)
        
        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
        
}


