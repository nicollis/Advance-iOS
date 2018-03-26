//
//  AppDelegate.swift
//  SurelyYouGist
//
//  Created by Michael Ward on 7/22/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

import UIKit
import GithubAccess

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GithubClientConsumer {
    
    class ConcreteUrlOpener : GithubURLOpener {
        func openURL(_ url: URL) {
            UIApplication.shared.openURL(url)
        }
    }
                            
    var window: UIWindow?
    var githubClient: GithubClient? = GithubClient(urlOpener: ConcreteUrlOpener())

    func application(_ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        let navController = self.window!.rootViewController as! UINavigationController
        
        if let clientConsumer = navController.topViewController as? GithubClientConsumer {
            clientConsumer.githubClient = githubClient
        }
        
        return true
    }
    
    func application(_ app: UIApplication,
             open url: URL,
                 options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool
    {
        // pack up the posted URL into an notification
        let userInfo = [SygistOpenURLInfoKey:url]
        let nc = NotificationCenter.default
        nc.post(name: .SygistDidReceiveURLNotification,
            object: self, userInfo: userInfo)
        
        return true
    }
    
    
}

