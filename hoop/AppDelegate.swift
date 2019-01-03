//
//  AppDelegate.swift
//  hoop
//
//  Created by Clément on 14/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit
import FacebookCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var me: profile? = nil
    
    enum ScreenToShow: String {
        case login = "login"
//        case tunnel
        case parameters = "parameters"
        case tutorial = "tutorial"
        case map = "map"
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // App Setup
        setupRouting()
        setupFacebook(with: application, and:launchOptions)
        setupAccountKit()
        
        // Data persistence management
        setupData()
        
        // First VC Selection
        window = UIWindow(frame: UIScreen.main.bounds)
        showFirstViewController(selectFirstViewController())
        window?.makeKeyAndVisible()
        
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

// Setups

extension AppDelegate {
    
    func setupData() {
        let defaults = Defaults()
        if let retrievedMe = defaults.get(for: .me) {
            me = retrievedMe
            if let token = retrievedMe.token {
                HoopNetworkApi.appToken = token
            }
        }
    }
    
    func setupRouting() {
        let router = Router.shared
        router.map("/tutorial", controllerClass: TutorialViewController.self)
        router.map("/parameters", controllerClass: ParametersViewController.self)
        router.map("/faq", controllerClass: FaqViewController.self)
        router.map("/web/:target", controllerClass: WebViewController.self)
        router.map("/map", controllerClass: MapViewController.self)
        router.map("/profile/:profileId", controllerClass: ProfileViewController.self)
        router.map("/conversation", controllerClass: ConversationViewController.self)
        router.map("/chat/:profileId", controllerClass: ChatViewController.self)
    }
    
    func setupFacebook(with application: UIApplication,and launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        // Facebook Init Stuffs
    }
    
    func setupAccountKit() {
        // AccountKit Init Stuffs
    }
}

extension AppDelegate {
    func selectFirstViewController() -> ScreenToShow{
        if let me = me {
            if let _ = me.token {
                if let _ = me.reached_map {
                    return .map
                } else if let _ = me.saw_tutorial {
                    return .parameters
                } else {
                    return .tutorial
                }
            } else {
                return .login
            }
        } else {
            return .login
        }
    }
}

// routing calls

extension AppDelegate{
    
    func showFirstViewController(_ toShow:ScreenToShow) {
        #if DEBUG
        print("Going to -> \(toShow.rawValue)")
        #endif
        switch toShow {
        case .login:
            showLogin()
        case .tutorial:
            showTutorial()
        case .parameters:
            showParameters()
        default:
            showLogin()
        }
    }
    
    func showInNavigationViewController(_ vc: UIViewController) {
        let navigationController = UINavigationController(rootViewController: vc)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func showLogin() {
        let loginController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        showInNavigationViewController(loginController!)
    }
    
    func showParameters() {
        let paramsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ParametersViewController") as? ParametersViewController
        showInNavigationViewController(paramsController!)
    }
    
    func showTutorial() {
        let tutoController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TutorialViewController") as? TutorialViewController
        showInNavigationViewController(tutoController!)
    }
    
    func showMap() {
        let mapController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as? MapViewController
        showInNavigationViewController(mapController!)
        //window?.rootViewController = mapController!
    }
    
}
