//
//  FileViewController.swift
//  SurelyYouGist
//
//  Created by Michael Ward on 7/22/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

import UIKit

class FileViewController: UIViewController, GithubClientConsumer {

    @IBOutlet var textView: UITextView?
    var githubClient: GithubClient?
    var fileToShow: GithubFile?
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let realTextView = textView {
            if let url = fileToShow?.remoteURL {
                _ = githubClient?.fetchStringAtURL(url) { (result: GithubResult<String>) -> Void in
                    switch result {
                    case .success(let text):
                        DispatchQueue.main.async {
                            realTextView.text = text
                        }
                    case .failure(let error):
                        print("ERROR: couldn't download file at \(url) as a string: \(error)")
                    }

                }
            } else {
                print("ERROR: file \(String(describing: fileToShow)) has no remoteURL")
            }
        } else {
            print("ERROR: file VC has no textView")
        }
    }
}
