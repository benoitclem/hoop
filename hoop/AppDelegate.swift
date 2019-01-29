//
//  AppDelegate.swift
//  hoop
//
//  Created by Clément on 14/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit
import FacebookCore
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static var me: profile? = nil
    
    enum ScreenToShow: String {
        case login = "login"
        case parameters = "parameters"
        case tunnel = "tunnel"
        case map = "map"
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // App Setup
        setupRouting()
        setupFacebook(with: application, and:launchOptions)
        setupBackgroundFetch(with: application)
        
        // Data persistence management
        setupData()
        
        let notificationOption = launchOptions?[.remoteNotification]
        
        if let notification = notificationOption as? [String: AnyObject] {
            if let aps = notification["aps"] as? [String: AnyObject] {
                handleNotificationFromInactiveApp(aps)
                // Do some fancy stuff to run the app form the notification
                // Basically goes to chatview
            }
            
        } else {
            // First VC Selection
            window = UIWindow(frame: UIScreen.main.bounds)
            showFirstViewController(selectFirstViewController())
            window?.makeKeyAndVisible()
        }
        
        // Alay respond true
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return SDKApplicationDelegate.shared.application(app, open: url, options: options)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

// Notification

extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print(deviceTokenString)
        Defaults().set(deviceTokenString, for: .deviceToken)
        if(HoopNetworkApi.appToken != nil) {
            let _ = HoopNetworkApi.sharedInstance.postDevice(withDeviceId: deviceTokenString)
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        handleNotificationFromActiveApp(userInfo)
    }
    
    func handleNotificationFromInactiveApp(_ aps: [String: AnyObject]) {
        let profileId = 1 // fake it for the moment
        if let chatVC = try? Router.shared.matchControllerFromStoryboard("/chat/\(profileId)",storyboardName: "Main") as! UIViewController,
            let mapVC = try? Router.shared.matchControllerFromStoryboard("/map",storyboardName: "Main") as! UIViewController {
            showInNavigationViewController([mapVC,chatVC])
        }
    }
    
    func handleNotificationFromActiveApp(_ userInfo: [AnyHashable : Any]) {
    
        let nData = notificationData(with: userInfo)
        // Increase the new message count
        //let nMsg = UserDefaults.standard.integer(forKey: "newMessages")
        // UserDefaults.standard.set(badge, forKey: "newMessages")
        if let badge = nData.badge {
            UIApplication.shared.applicationIconBadgeNumber = badge
        }
        
        // Notify the other listening page that we received a notif
        if (UIApplication.shared.applicationState == .active) {
            NotifiableUIViewController.postNotification(with: nData)
        } else if(UIApplication.shared.applicationState == .inactive) {
//            var infoCpy = aps
//            infoCpy[AnyHashable("back")] = 1
//            //self.notifProxy.notifData = infoCpy
        }
    }
        
}

// Setups

extension AppDelegate {
    
    func setupData() {
        let defaults = Defaults()
        if let retrievedMe = defaults.get(for: .me) {
            AppDelegate.me = retrievedMe
            if let token = retrievedMe.token {
                HoopNetworkApi.appToken = token
            }
        }
    }
    
    func setupRouting() {
        let router = Router.shared
        router.map("/inputAge", controllerClass: InputAgeViewController.self)
        router.map("/inputEmail", controllerClass: InputEmailViewController.self)
        router.map("/inputName", controllerClass: InputNameViewController.self)
        router.map("/inputGender", controllerClass: InputGenderViewController.self)
        router.map("/parameters", controllerClass: ParametersViewController.self)
        router.map("/faq", controllerClass: FaqViewController.self)
        router.map("/web/:target", controllerClass: WebViewController.self)
        router.map("/map", controllerClass: MapViewController.self)
        router.map("/profile/:profileId", controllerClass: ProfileViewController.self)
        router.map("/conversations", controllerClass: ConversationViewController.self)
        router.map("/chat/:profileId", controllerClass: ChatViewController.self)
    }
    
    func setupFacebook(with application: UIApplication,and launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        // Facebook Init Stuffs
    }
    
    func setupBackgroundFetch(with application: UIApplication) {
        application.setMinimumBackgroundFetchInterval(5*60)
        //application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
    }

    func selectFirstViewController() -> ScreenToShow{
        if let me = AppDelegate.me {
            if let _ = me.token {
                if let _ = me.reached_map {
                    return .map
                } else if let _ = me.name, let _ = me.email, let _ = me.dob,let _ = me.gender {
                    return .parameters
                } else {
                    return .tunnel
                }
            } else {
                return .login
            }
        } else {
            return .login
        }
    }
    
    func showFirstViewController(_ toShow:ScreenToShow) {
        #if DEBUG
        print("Going to -> \(toShow.rawValue)")
        #endif
        switch toShow {
        case .login:
            showLogin()
        case .tunnel:
            showTunnel()
        case .parameters:
            showParameters()
        case .map:
            showMap()
        default:
            showLogin()
        }
    }
    
    func showInNavigationViewController(_ vc: [UIViewController]) {
        let navigationController = UINavigationController()
        navigationController.setViewControllers(vc, animated: false)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func showLogin() {
        let loginController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        showInNavigationViewController([loginController!])
    }
    
    func showParameters() {
        let paramsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ParametersViewController") as? ParametersViewController
        showInNavigationViewController([paramsController!])
    }
    
    func showTunnel() {
        let tutoController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InputNameViewController") as? InputNameViewController
        showInNavigationViewController([tutoController!])
    }
    
    func showMap() {
        let mapController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as? MapViewController
        showInNavigationViewController([mapController!])
        //window?.rootViewController = mapController!
    }
    
    func showMapBox() {
        let mapBoxController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapBoxViewController") as? MapBoxViewController
        showInNavigationViewController([mapBoxController!])
    }
    
}

