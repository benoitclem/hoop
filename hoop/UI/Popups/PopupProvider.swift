//
//  PopupProvider.swift
//  hoop
//
//  Created by Clément on 20/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit
import SwiftEntryKit
import Kingfisher
import Futures

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
    
    static func showErrorNote(_ text: String) {
        var attributes: EKAttributes
        
        // Fill the attribute structure
        attributes = .topNote
        attributes.hapticFeedbackType = .error
        attributes.displayDuration = .infinity
        attributes.popBehavior = .animated(animation: .translation)
        attributes.entryBackground = .color(color: .red)
        attributes.statusBar = .light
        
        // Fill up the Note message View
        let style = EKProperty.LabelStyle(font:  UIFont.MainFontLight(ofSize: 12.0), color: .white, alignment: .center)
        let labelContent = EKProperty.LabelContent(text: text, style: style)
        
        let contentView = EKNoteMessageView(with: labelContent)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
    
    static func showEtHoopPopup(recipient:String, thumbUrl:URL?, sendClosure: ((_ message:String)->())?, cancelClosure: (()->())? ) {
        var attributes: EKAttributes

        attributes = .float
        attributes.windowLevel = .normal
        attributes.position = .center
        attributes.displayDuration = .infinity

        attributes.entranceAnimation = .init(translate: .init(duration: 0.65, anchorPosition: .bottom,  spring: .init(damping: 1, initialVelocity: 0)))
        attributes.exitAnimation = .init(translate: .init(duration: 0.65, anchorPosition: .top, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.65, spring: .init(damping: 1, initialVelocity: 0))))

        attributes.entryInteraction = .absorbTouches
        //attributes.screenInteraction = .dismiss
        
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        attributes.positionConstraints.keyboardRelation = keyboardRelation

        attributes.entryBackground = .color(color: .white)
        attributes.screenBackground = .color(color: UIColor.gray.withAlphaComponent(0.4))

        attributes.border = .value(color: UIColor(white: 0.6, alpha: 1), width: 1)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 3))
        attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
        attributes.statusBar = .light

        let contentView = MessagePopupView(recipient, thumbUrl, sendClosure, cancelClosure)
        SwiftEntryKit.display(entry: contentView, using: attributes, presentInsideKeyWindow: true)

    }
    
    static func showTwoChoicesPopup(
        icon:UIImage?,
        title:String,
        content:String,
        okTitle:String?,
        nokTitle:String?,
        okClosure: (()->())?,
        nokClosure: (()->())? )
    {
        var attributes: EKAttributes
        
        attributes = .float
        attributes.windowLevel = .normal
        attributes.position = .center
        attributes.displayDuration = .infinity
        
        attributes.entranceAnimation = .init(translate: .init(duration: 0.65, anchorPosition: .bottom,  spring: .init(damping: 1, initialVelocity: 0)))
        attributes.exitAnimation = .init(translate: .init(duration: 0.65, anchorPosition: .top, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.65, spring: .init(damping: 1, initialVelocity: 0))))
        
        attributes.entryInteraction = .absorbTouches
        attributes.screenInteraction = .dismiss
        
        attributes.entryBackground = .color(color: .white)
        attributes.screenBackground = .color(color: UIColor.gray.withAlphaComponent(0.4))
        
        attributes.border = .value(color: UIColor(white: 0.6, alpha: 1), width: 1)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 3))
        attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
        attributes.statusBar = .light
        
        let contentView = TwoChoicesPopupView(icon: icon,
                                              title: title,
                                              content: content,
                                              okTitle: okTitle,
                                              nokTitle: nokTitle,
                                              okClosure: okClosure,
                                              nokClosure: nokClosure)
        SwiftEntryKit.display(entry: contentView, using: attributes, presentInsideKeyWindow: true)
    }
    
    
    
    static func showInformPopup(with image:UIImage,_ titleText: String,_ descriptionText: String,_ buttonText:String,_ buttonAction:@escaping (()->())) {
        var attributes: EKAttributes
        
        // Fill the attribute structure
        attributes = .centerFloat
        attributes.hapticFeedbackType = .success
        attributes.displayDuration = .infinity
        attributes.popBehavior = .animated(animation: .translation)
        attributes.entryBackground = .color(color: .red)
        attributes.screenBackground = .color(color: UIColor.gray.withAlphaComponent(0.4))
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
    
    static func showMessageToast(with title: String,_ description: String,_ whenString: String,_  thumb: UIImage?, tapAction: (()->())? ) {
        var attributes: EKAttributes
        
        // Fill the attribute structure
        attributes = .topToast
        attributes.windowLevel = .normal
        attributes.hapticFeedbackType = .success
        attributes.entryBackground = .color(color: .blue)
        attributes.entranceAnimation = .translation
        attributes.exitAnimation = .translation
        attributes.scroll = .edgeCrossingDisabled(swipeable: true)
        attributes.displayDuration = 4
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10))
        if let action = tapAction {
            attributes.entryInteraction.customTapActions.append(action)
        }
        
        // Fill up the toast
        let title = EKProperty.LabelContent(text: title, style: .init(font: UIFont.MainFontLight(ofSize: 12.0), color: .white))
        let description = EKProperty.LabelContent(text: description, style: .init(font: UIFont.MainFontLight(ofSize: 12.0), color: .white))
        let time = EKProperty.LabelContent(text: whenString, style: .init(font:  UIFont.MainFontLight(ofSize: 12.0), color: .white))
        let image = EKProperty.ImageContent.thumb(with: thumb ?? UIImage(named:"thumb_placeholder")!, edgeSize: 35)
        let simpleMessage = EKSimpleMessage(image: image, title: title, description: description)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage, auxiliary: time)
        
        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
    
    static func showMessageToast(with nData: notificationData, tapAction action: ((Int)->())?) {
        if let title = nData.title, let body = nData.body, let url = nData.atturl, let profileId = nData.clientId {
            let downloader = ImageDownloader.default
            downloader.downloadImage(with: url) { result in
                switch result {
                case .success(let value):
                    PopupProvider.showMessageToast(with: title, body, "now", value.image, tapAction: { action?(profileId) })
                case .failure( _):
                    PopupProvider.showMessageToast(with: title, body, "now", nil, tapAction: {action?(profileId)})
                }
            }
        }
    }

    
    
}



// Where all the popup messages are called
extension PopupProvider {

    static func showNoRemainingConversationPopup() {
        PopupProvider.showTwoChoicesPopup(icon: UIImage(named: "sadscreen"),
                                          title: "Désolé",
                                          content: "Tu n'as plus de conversation, demain est un autre jour et ca c'est cool",
                                          okTitle: "ok",
                                          nokTitle: nil,
                                          okClosure: nil,
                                          nokClosure: nil)
    }
    
    static func showEtHoopPopup(profile:profile) {
        if let me = AppDelegate.me {
            if me.gender == 1 && me.n_remaining_conversations == 0 && profile.id != 1 {
                PopupProvider.showNoRemainingConversationPopup()
                return
            }
            PopupProvider.showEtHoopPopup(recipient: profile.name ?? "No name", thumbUrl: profile.thumb ?? nil, sendClosure: { messageString in
                print(messageString)
                let msg = message(with: messageString, and: profile.id!)
                HoopNetworkApi.sharedInstance.postMessage(msg)?.whenFulfilled{ _ in
                    if me.gender == 1 {
                        if let n  = me.n_remaining_conversations {
                            me.n_remaining_conversations = n - 1
                            me.save()
                        }
                    }
                }
            }, cancelClosure: nil)
        }
    }
}
