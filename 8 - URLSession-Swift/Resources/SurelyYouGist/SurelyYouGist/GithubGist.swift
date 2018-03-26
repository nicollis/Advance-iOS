//
//  Gist.swift
//  SurelyYouGist
//
//  Created by Michael Ward on 7/22/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

import Foundation

class GithubGist: NSObject {
    let remoteURL: URL
    var userDescription: String = ""
    var files: [GithubFile] = []
    
    init(url remoteURL: URL) {
        self.remoteURL = remoteURL
    }
}
