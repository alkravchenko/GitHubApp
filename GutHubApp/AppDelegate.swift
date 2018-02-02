
//
//  AppDelegate.swift
//  GutHubApp
//
//  Created by Kravchenko on 27.01.2018.
//  Copyright © 2018 WaveAccess. All rights reserved.
//

import UIKit
import OAuth2

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    /// App delegate
    static var shared: AppDelegate {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError("Incorrect application configuration") }
        return appDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
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
    
    // MARK: - OAuth Athorization

    private(set) var oauth: OAuth2CodeGrant?
    private(set) var accessToken: String?
    
    func authorize(from viewController: UIViewController) {
        accessToken = nil
        AppDelegate.shared.oauth = OAuth2CodeGrant(settings: [
            "client_id": "6102e1d5e4a8ea8eb006",
            "client_secret": "0b6a110526a5600f48cc1af89db838fbf03bffc7",
            "authorize_uri": "https://github.com/login/oauth/authorize",
            "token_uri": "https://github.com/login/oauth/access_token",
            "redirect_uris": ["githubapp://authorize"],
            "scope": "public_repo",
            "secret_in_body": true,
            "keychain": false,
            ] as OAuth2JSON)
        
        AppDelegate.shared.oauth?.authorizeEmbedded(from: viewController) { authParameters, error in
            if let parameters = authParameters, let accessToken = parameters["access_token"] as? String {
                self.accessToken = accessToken
            }
        }
    }
    

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        oauth?.handleRedirectURL(url)
        return true
    }


}

