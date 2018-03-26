//
//  GithubURLOpener.swift
//  SurelyYouGist
//
//  Created by Mark Dalrymple on 9/18/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import Foundation

// cannot call UIApplication openURL from inside an extension, so bounce the OAuth
// URLOpening through this


public protocol GithubURLOpener {
    func openURL(_ url: URL)
}
