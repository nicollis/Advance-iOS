//
//  Copyright © 2015 Big Nerd Ranch
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var tabDelegate: TabDelegate! = nil
    
    func application(_ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        guard let tabBarController = window?.rootViewController as? UITabBarController else {
            preconditionFailure("Unexpected root hierarchy in main storyboard")
        }
        tabDelegate = TabDelegate()
        tabDelegate.layoutDirection = application.userInterfaceLayoutDirection
        tabBarController.delegate = tabDelegate
        return true
    }

}

