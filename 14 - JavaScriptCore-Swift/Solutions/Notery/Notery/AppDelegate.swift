//
//  AppDelegate.swift
//  Notery
//
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        guard let splitViewController = window?.rootViewController as? UISplitViewController,
            let listNavigationController = splitViewController.viewControllers[0] as? UINavigationController,
            let listController = listNavigationController.topViewController as? DocumentListTableViewController,
            let documentNavigationController = splitViewController.viewControllers[1] as? UINavigationController,
            let documentController = documentNavigationController.topViewController as? SingleDocumentViewController else {
            assertionFailure("App doesn't have expected setup from storyboard")
            return false
        }
        
        splitViewController.delegate = listController
        listController.documentViewController = documentController
        documentController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        
        return true
    }

}
