//
//  ShareViewController.swift
//  Gistizer
//
//  Created by Mark Dalrymple on 2/5/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import GithubAccess

class ShareViewController: SLComposeServiceViewController {

    var isPublic: Bool = true
    var publicPrivateConfigurationItem: SLComposeSheetConfigurationItem!

    override func viewDidLoad() {
        //let token = GithubKeychain.token()
        //print("Did we get a token? \( token == nil ? "no" : "yes")")
        //
        //let defs = NSUserDefaults.init(suiteName: "group.com.bignerdranch.SurelyYouGist")
        //let username = defs?.stringForKey("GithubUserNameDefaultsKey")
        //
        //print("Got username: \(username)")
        
        loadSafariSelection()
    }
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    func pushPublicPrivateGistChooser() {
        let storyboard = UIStoryboard(name: "MainInterface", bundle: nil)
        let publicPrivateTVC = storyboard.instantiateViewController(withIdentifier: "PublicPrivateGist")
            as! PublicPrivateGistChooserTableViewController
        
        publicPrivateTVC.isPublic = isPublic
        publicPrivateTVC.completion = { isPublic in
            self.isPublic = isPublic
            self.publicPrivateConfigurationItem.value = isPublic ? "Public" : "Private"
        }            
        pushConfigurationViewController(publicPrivateTVC)
    }
    
    override func didSelectPost() {
        //guard let context = self.extensionContext,
        //    let items = context.inputItems as? [NSExtensionItem],
        //    let item = items.first,
        //    let string = item.attributedContentText else {
        //        self.extensionContext?.completeRequestReturningItems([], completionHandler: nil)
        //        return
        //}
        
        guard let plainString = self.textView.text else { return }
        
        let githubClient = GithubClient()
        githubClient.postGist(plainString, description: "hello extension!", 
            isPublic: isPublic) { _ in
                self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
    }
    
    fileprivate func loadSafariSelection() {
        guard let context = self.extensionContext,
        let items = context.inputItems as? [NSExtensionItem],
        let item = items.first,
        let attachments = item.attachments as? [NSItemProvider],
        let provider = attachments.first else {
            return
        }
        if provider.hasItemConformingToTypeIdentifier(String(kUTTypePropertyList)) {
            provider.loadItem(forTypeIdentifier: String(kUTTypePropertyList), options: [:]) { item, error in
                if let selectedText = item as? String {
                    print("got selected text \(selectedText)")
                    
                    OperationQueue.main.addOperation() {
                        self.textView.text = selectedText
                    }
                }
            }
        }
    }
    
    override func configurationItems() -> [Any]! {
        let githubClient = GithubClient()
        
        guard let accountNameItem = SLComposeSheetConfigurationItem() else {
            return []
        }
        
        accountNameItem.title = "Account"
        accountNameItem.value = githubClient.userID
        
        publicPrivateConfigurationItem = SLComposeSheetConfigurationItem()
        publicPrivateConfigurationItem.title = "Access"
        publicPrivateConfigurationItem.value = isPublic ? "Public" : "Private"

        publicPrivateConfigurationItem.tapHandler =  { [unowned self] in
            self.pushPublicPrivateGistChooser()
        }
        
        // return [accountNameItem]
        return [ accountNameItem, publicPrivateConfigurationItem ]
    }
    
}


