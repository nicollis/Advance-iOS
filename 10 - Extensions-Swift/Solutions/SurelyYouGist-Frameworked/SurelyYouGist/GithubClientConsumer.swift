//
//  GithubClientConsumer.swift
//  SurelyYouGist
//
//  Created by Chris Morris on 8/12/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

import Foundation

@objc public protocol GithubClientConsumer {
    var githubClient: GithubClient? {get set}
}
