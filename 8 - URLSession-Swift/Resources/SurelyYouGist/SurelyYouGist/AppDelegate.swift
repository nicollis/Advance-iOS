//
//  AppDelegate.swift
//  SurelyYouGist
//
//  Created by Michael Ward on 7/22/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

import UIKit

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
    
}

