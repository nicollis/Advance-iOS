//
//  WebError.swift
//  SurelyYouGist
//
//  Created by Michael Ward on 10/6/15.
//  Copyright © 2015 Big Nerd Ranch. All rights reserved.
//

import Foundation

public enum GithubError: Error {
    case jsonSerializationError(String)
    case jsonContentError(String)
    case connectionError(String)
    case invalidDataError(String)
    case usernameError
    case unknownHTTPError(Int)
    case authenticationError
}
