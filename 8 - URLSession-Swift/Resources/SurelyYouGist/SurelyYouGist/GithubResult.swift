//
//  GithubResult.swift
//  SurelyYouGist
//
//  Created by Michael Ward on 10/9/15.
//  Copyright © 2015 Big Nerd Ranch. All rights reserved.
//

import Foundation

enum GithubResult<T> {
    case success(T)
    case failure(GithubError)
}
