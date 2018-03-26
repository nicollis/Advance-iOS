//
//  GithubImporter.swift
//  SurelyYouGist
//
//  Created by Michael Ward on 7/23/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

import UIKit

private typealias JSONDictionary = [String : AnyObject]

class GithubImporter {

    class func gistsFromData(_ data: Data) throws -> [GithubGist]  {
        do {
            if let gistDicts = try JSONSerialization.jsonObject(with: data, options: []) as? [JSONDictionary] {
                return try gistDicts.map { try gistFromJSONGistDict($0) }
            } else {
                throw GithubError.jsonContentError("JSON top level object wasn't an array of gist dictionaries as expected")
            }
        } catch (let jsonError as NSError) {
            throw GithubError.jsonSerializationError(jsonError.localizedDescription)
        }
    }
    
    class func userIDFromData(_ data: Data) throws -> String {
        do {
            if let userDict = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary {
                return try userIDFromJSONUserDict(userDict)
            } else {
                throw GithubError.jsonContentError("JSON top level object wasn't an array of gist dictionaries as expected")
            }
        } catch (let jsonError as NSError) {
            throw GithubError.jsonSerializationError(jsonError.localizedDescription)
        }
    }
    
    class func stringFromData(_ data: Data) throws -> String {
        if let string = String(data: data, encoding: String.Encoding.utf8) {
            return string
        } else {
            throw GithubError.invalidDataError("Could not decode data as UTF8 string")
        }
    }
}

// MARK: - Private helper methods
extension GithubImporter {
    
    fileprivate class func gistFromJSONGistDict(_ gistDict: JSONDictionary) throws -> GithubGist {
        guard let gistURLString = gistDict["url"] as? String,
            let gistURL = URL(string: gistURLString),
            let userDescription = gistDict["description"] as? String,
            let fileDictDict = gistDict["files"] as? [String : JSONDictionary]
            else {
                throw GithubError.jsonContentError("Failed to unpack a gist dictionary")
        }
        
        let newGist = GithubGist(url: gistURL)
        newGist.userDescription = (userDescription == "") ? "(untitled)" : userDescription
        newGist.files = try fileDictDict.values.map { try fileFromJSONFileDict($0) }
        return newGist
    }
    
    fileprivate class func fileFromJSONFileDict(_ fileDict: JSONDictionary) throws -> GithubFile {
        guard let fileURLString = fileDict["raw_url"] as? String,
            let fileURL = URL(string: fileURLString),
            let fileName = fileDict["filename"] as? String,
            let fileSize = fileDict["size"] as? Int
            else {
                throw GithubError.jsonContentError("Failed to unpack content of a file dictionary")
        }
        
        let newFile = GithubFile(fileName: fileName, url: fileURL, size: fileSize)
        return newFile
    }
    
    fileprivate class func userIDFromJSONUserDict(_ userDict: JSONDictionary) throws -> String {
        guard let userID = userDict["login"] as? String
            else {
                throw GithubError.jsonContentError("Failed to unpack content of a user dictionary")
        }

        return userID
    }
    
}
