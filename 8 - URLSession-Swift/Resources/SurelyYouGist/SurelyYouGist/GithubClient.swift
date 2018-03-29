//
//  GithubClient.swift
//  SurelyYouGist
//
//  Created by Michael Ward on 7/22/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

import UIKit

let GithubUserNameDefaultsKey = "GithubUserNameDefaultsKey"
let GithubAuthTokenDefaultsKey = "GithubAuthTokenDefaultsKey"
let SharedDefaultsSuiteName = "group.digital.ollisllc.SurelyYouGist"

typealias TaskID = UUID

class GithubClient: NSObject {
    
    // MARK: - Vars and Lets
    // TODO: - This is so horrable remove this before commiting
    let clientID = "80bbc8f793514c211148"
    let clientSecret = "ae6466c5a4993328ae53e16dbc56ada094cd061e"
    let clientRedirectURLString = "sygist://oauth/callback/"
    
    // From documentation at https://developer.github.com/v3/oauth/
    fileprivate struct GithubURLs {
        static let authorizeURL = URL(string: "https://github.com/login/oauth/authorize")!
        static let tokenURL = URL(string: "https://github.com/login/oauth/access_token")!
        static let apiBaseURL = URL(string: "https://api.github.com/")!
    }
    
    // Our own stuff

    fileprivate var urlSession: URLSession = URLSession.shared
    fileprivate var inflightTasks: [UUID : URLSessionTask] = [:]
    fileprivate var currentStateString: String = UUID().uuidString
    
    // MARK: - OAuth
    
    // OAuth step 1 get a authorization grant
    func beginAuthorizationByFetchingGrant() {
        currentStateString = UUID().uuidString
        
        var urlComponents = URLComponents(url: GithubURLs.authorizeURL, resolvingAgainstBaseURL: true)!
        
        let queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: clientRedirectURLString),
            URLQueryItem(name: "state", value: currentStateString),
            URLQueryItem(name: "scope", value: "gist")
        ]
        
        urlComponents.queryItems = queryItems
        
        if let url = urlComponents.url {
            UIApplication.shared.open(url)
        }
        // Register for open URL notifications
        NotificationCenter.default.addObserver(self, selector: #selector(GithubClient.observationSygistDidOpenURLNotification(_:)), name: .SygistDidReceiveURLNotification, object: nil)
    }
    
    // OAuth step 2: user accepts, which calls back to our app with the request code
    @objc func observationSygistDidOpenURLNotification(_ note: Notification) {
        guard let url = (note as NSNotification).userInfo?[SygistOpenURLInfoKey] as? URL,
            let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems,
            url.host == "oauth" && url.path == "/callback" else {
                print("SygistDidReceiveURLNotification had invalid or non-URL SygistOpenURLInfoKey")
                return
        }
        
        for queryItem in queryItems where queryItem.name == "code" {
            let grantCode = queryItem.value!
            fetchTokenUsingGrant(grantCode)
        }
    }
    
    // OAuth step 3: we post the request code back to GitHub.
    func fetchTokenUsingGrant(_ grantCode:String) {
        
        let bodyDict = [
            "client_id"     : clientID,
            "client_secret" : clientSecret,
            "code"          : grantCode,
            "redirect_uri"  : clientRedirectURLString
        ]
        
        let url = GithubURLs.tokenURL
        let request = NSMutableURLRequest(url: url)
        let bodyData = try! JSONSerialization.data(withJSONObject: bodyDict, options: [])
        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.setValue(nil, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        _ = fetchDataWithRequest(request as URLRequest, withCompletion: { (result) in
            switch result {
            case .success(let data):
                do {
                    let token = try GithubImporter.tokenFromData(data)
                    self.accessToken = token
                    print("Fetched access token \(token)")
                } catch (let parseError) {
                    print("Error: Can't parse token data: \(parseError)")
                }
            case .failure(let error):
                print("Error: No token data: \(error)")
            }
        })
    }
    
    // Github Credentials
    var userID: String? {
        get {
            let defaults = UserDefaults.standard
            var id = defaults.object(forKey: GithubUserNameDefaultsKey) as? String
            if id == nil {
                let defaultsSuite = UserDefaults(suiteName: SharedDefaultsSuiteName)
                id = defaultsSuite?.object(forKey: GithubUserNameDefaultsKey) as? String
            }
            return id
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: GithubUserNameDefaultsKey)
            defaults.synchronize()
            
            let defaultsSuite = UserDefaults(suiteName: SharedDefaultsSuiteName)
            defaultsSuite?.set(newValue, forKey: GithubUserNameDefaultsKey)
            defaultsSuite?.synchronize()
        }
    }
    
    fileprivate var accessToken: String? {
        get {
            return GithubKeychain.token()
        }
        set {
            _ = GithubKeychain.storeToken(newValue)
            configureSession()
        }
    }
    
    override init() {
        super.init()
        configureSession()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Requests

    func fetchGistsWithCompletion(_ completion: @escaping (GithubResult<[GithubGist]>) -> Void ) -> TaskID? {
        
        guard let username = self.userID else {
            completion(.failure(GithubError.usernameError))
            return nil
        }
        
        let url = GithubURLs.apiBaseURL.appendingPathComponent("users/\(username)/gists")
        let request = URLRequest(url: url)
        return fetchDataWithRequest(request) { result in
            switch result {
            case .success(let data):
                do {
                    let gists = try GithubImporter.gistsFromData(data)
                    completion(.success(gists))
                } catch (let parseError) {
                    completion(.failure(parseError as! GithubError))
                }
            case .failure(let fetchError):
                completion(.failure(fetchError))
            }
        }
    }
    
    func fetchUsernameWithCompletion(_ completion: @escaping (GithubResult<String>) -> Void ) -> TaskID? {
        let url = GithubURLs.apiBaseURL.appendingPathComponent("user")
        let request = URLRequest(url: url)
        return fetchDataWithRequest(request) { result in
            switch result {
            case .success(let data):
                do {
                    let userID = try GithubImporter.userIDFromData(data)
                    completion(.success(userID))
                } catch (let parseError) {
                    completion(.failure(parseError as! GithubError))
                }
            case .failure(let fetchError):
                completion(.failure(fetchError))
            }
        }
    }
    
    func fetchStringAtURL(_ url: URL, withCompletion completion: @escaping (GithubResult<String>) -> Void ) -> TaskID? {
        let request = URLRequest(url: url)
        return fetchDataWithRequest(request) { result in
            switch result {
            case .success(let data):
                do {
                    let string = try GithubImporter.stringFromData(data)
                    completion(.success(string))
                } catch (let parseError) {
                    completion(.failure(parseError as! GithubError))
                }
            case .failure(let fetchError):
                completion(.failure(fetchError))
            }
        }
    }

    // MARK: - Funnel fetcher (all the other fetchers route through here)
    
    fileprivate func fetchDataWithRequest(_ request: URLRequest,
                    withCompletion completion: @escaping (GithubResult<Data>) -> Void ) -> TaskID {
    
        let taskID = TaskID()
        
        let task = urlSession.dataTask(with: request, completionHandler: {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            defer { self.removeTaskWithID(taskID) }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                completion(.failure(GithubError.connectionError(error!.localizedDescription)))
                return
            }
            
            switch response.statusCode {
            case 200:
                completion(.success(data))
            case 401:
                completion(.failure(GithubError.authenticationError))
            default:
                completion(.failure(GithubError.unknownHTTPError(response.statusCode)))
            }
            
            print("Received status code \(response.statusCode) and \(data.count) bytes of data from \(String(describing: request.url))")
        })
        
        inflightTasks[taskID] = task
        task.resume()
        return taskID
    }
    
    // MARK: - Task and Session Management
    
    func removeTaskWithID(_ id: TaskID) {
        if let task = inflightTasks[id] {
            task.cancel()
        }
        inflightTasks[id] = nil
    }
    
    fileprivate func configureSession() {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "Accept" : "application/json"
        ]
        
        if let token = accessToken {
            config.httpAdditionalHeaders!["Authorization"] = "Bearer \(token)"
        }
        
        urlSession = URLSession(configuration: config)
    }

}
