//
//  AppDelegate.swift
//  SurelyYouGist
//
//  Created by Michael Ward on 7/22/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

import UIKit

extension NSNotification.Name {
    static public let SygistDidReceiveURLNotification = NSNotification.Name("ApplicationDidReceiveURLNotification")
}
let SygistOpenURLInfoKey = "ApplicationOpenURLInfoKey"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GithubClientConsumer {
                            
    var window: UIWindow?
    var githubClient: GithubClient? = GithubClient()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let navController = self.window!.rootViewController as! UINavigationController
        
        if let clientConsumer = navController.topViewController as? GithubClientConsumer {
            clientConsumer.githubClient = githubClient
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let userInfo = [SygistOpenURLInfoKey:url]
        let nc = NotificationCenter.default
        nc.post(name: .SygistDidReceiveURLNotification, object: self, userInfo: userInfo)
        
        return true
    }
    
}

