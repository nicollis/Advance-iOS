//
//  ShareViewController.swift
//  Gistizer
//
//  Created by Mark Dalrymple on 9/18/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        let token = GithubKeychain.token()
        print("did we get a token?  \(token == nil ? "no" : "yes")")
        let defs = UserDefaults(suiteName: "group.com.borkware.SurelyYouGist2")
        let username = defs?.string(forKey: "GithubUserNameDefaultsKey")
        print("got username \(String(describing: username))")
    }

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        guard let context = self.extensionContext,
            let items = context.inputItems as? [NSExtensionItem],
            let item = items.first,
            let string = item.attributedContentText else {
                self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                return
        }
        
        let plainString = string.string
                
        let githubClient = GithubClient()
        githubClient.postGist(plainString, description: "hello extension!", 
            isPublic: true) { _ in
                self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
