//
//  File.swift
//  SurelyYouGist
//
//  Created by Michael Ward on 7/22/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

import Foundation

open class GithubFile: NSObject {
    open let remoteURL:URL
    open let fileName:String
    open var size:Int = 0
    
    init(fileName:String, url remoteURL:URL?, size:Int) {
        assert(remoteURL != nil, "Attempt to initialize GithubFile \(fileName) with nil remoteURL")
        self.remoteURL = remoteURL!
        self.fileName = fileName
        self.size = size
    }
}
