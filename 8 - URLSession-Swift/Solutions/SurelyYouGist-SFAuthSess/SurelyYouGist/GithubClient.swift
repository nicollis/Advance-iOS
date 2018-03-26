//
//  GithubClient.swift
//  SurelyYouGist
//
//  Created by Michael Ward on 7/22/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

import UIKit
import SafariServices

let GithubUserNameDefaultsKey = "GithubUserNameDefaultsKey"
let GithubAuthTokenDefaultsKey = "GithubAuthTokenDefaultsKey"

typealias TaskID = UUID

class GithubClient: NSObject {
    
    // MARK: - Vars and Lets
    
    // ClientID and ClientSecret and callback URL associated with our registered GitHub app
    let clientID = "8f71a3a7ce7d9cd688a9"
    let clientSecret = "e1f9032b3e42f486933f96679e3742058584cc40"
    let clientRedirectURLString = "sygist://oauth/callback/"
    var authSession: SFAuthenticationSession?
    
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
    
    // Github Credentials
    var userID: String? {
        get {
            let defaults = UserDefaults.standard
            return defaults.object(forKey: GithubUserNameDefaultsKey) as? String
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: GithubUserNameDefaultsKey)
            defaults.synchronize()
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
                                          withCompletion completion: @escaping (GithubResult<Data>) -> Void ) -> TaskID
    {
        let taskID = TaskID()
        
        let task = urlSession.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            defer { self.removeTaskWithID(taskID) }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                completion(.failure(GithubError.connectionError(error!.localizedDescription)))
                return
            }
            
            switch response.statusCode {
            case 200: // OK
                completion(.success(data))
            case 401: // unauthorized
                completion(.failure(GithubError.authenticationError))
            default:
                completion(.failure(GithubError.unknownHTTPError(response.statusCode)))
            }
            
            print("Received status code \(response.statusCode) and \(data.count) bytes of data from \(request.url!)")
            
        }
        
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
    
    // MARK: - OAuth
    
    // OAuth step 1: we request an "authorization grant"
    // code via the browser
    func beginAuthorizationByFetchingGrant() {
        currentStateString = UUID().uuidString
        
        // Prepare the URL
        var urlComponents = URLComponents(url: GithubURLs.authorizeURL,
                                          resolvingAgainstBaseURL: true)!
        
        let queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: clientRedirectURLString),
            URLQueryItem(name: "state", value: currentStateString),
            URLQueryItem(name: "scope", value: "gist")
        ]
        
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else { return }
        
        // Request auth at the given URL
        authSession = SFAuthenticationSession(url: url, callbackURLScheme: "sygist") { (redirectURL, error) in
            guard let grantURL = redirectURL,
                  let queryItems = URLComponents(url: grantURL, resolvingAgainstBaseURL: true)?.queryItems,
                  grantURL.host == "oauth" && grantURL.path == "/callback" else {
                    print("Failed to parse grant token from \(String(describing: redirectURL))")
                    return
            }
            
            for queryItem in queryItems {
                if queryItem.name == "code" {
                    let grantCode = queryItem.value!
                    self.fetchTokenUsingGrant(grantCode)
                }
            }
        }
        authSession?.start()
        
    }
    
    // OAuth step 3: we post the request code back to GitHub,
    // requesting an actual OAuth token for future use
    func fetchTokenUsingGrant(_ grantCode:String) {
        
        let bodyDict = [
            "client_id"    : clientID,
            "client_secret": clientSecret,
            "code"         : grantCode,
            "redirect_uri" : clientRedirectURLString
        ]
        
        let url = GithubURLs.tokenURL
        let request = NSMutableURLRequest(url: url)
        let bodyData = try! JSONSerialization.data(withJSONObject: bodyDict, options: [])
        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.setValue(nil, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        _ = fetchDataWithRequest(request as URLRequest) { result in
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
        }
    }
}
