//
//  Users.swift
//  GutHubApp
//
//  Created by Kravchenko on 31.01.2018.
//  Copyright © 2018 WaveAccess. All rights reserved.
//

import UIKit

//MARK: - Protocol-oriented implementation of Users model controller functionality

//MARK: -

/// Protocol for `Users` model controller clients (implicity adds `usersModelController` property to class)
protocol Users: AnyObject {
    /// Property for access to Users model controller functionality
    var usersModelController: UsersModelController { get }
}

/// Protocol extension for `UIViewController` (add `usersModelController` implementation), other classes requires its own implementation
extension Users where Self: UIViewController {
    /// Property for access to `Users`s model controller functionality
    var usersModelController: UsersModelController {
        return UsersModelController.shared
    }
}

//MARK: - Users model controller

/// `Users` model controller
class UsersModelController {
    /// Shared `Repositories model` controller object (singleton). Can not be accesses outside this file (for preventing code connectivity problems). You shoul access to this property only via `Respository` protocol implementation.
    fileprivate static let shared = UsersModelController()

    /// Errors enum
    enum UsersError: Error {
        case emptyUser
        case requestFormat
        case requestFailed
        case responseFormat
        case dataToObjectFailed
        case userNotFound
        case notAuthorized
    }
    
    
    /// Session for requests
    private let urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.httpCookieAcceptPolicy = .never
        configuration.urlCache = nil
        URLCache.shared.removeAllCachedResponses()
        let session = URLSession(configuration: configuration)
        return session
    }()
    
    /// Current data task
    private var searchingTask: URLSessionDataTask?
    
    /// Helper for objects mapping
    func objects<T>(from data: Data) throws -> [T] where T : Decodable {
        guard let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any], let jsonObjects = jsonResponse["items"] as? [[String: Any]] else { throw UsersError.dataToObjectFailed }
        
        var objects = [T]()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        for jsonObject in jsonObjects {
            let objectData = try JSONSerialization.data(withJSONObject: jsonObject)
            let object = try decoder.decode(T.self, from: objectData)
            objects.append(object)
        }
        return objects
    }

    
    /// Method for search users
    func searchUsers(_ user: String, completion: @escaping (_ result: SearchingResult, _ users: [User]?, _ error: Error?) -> ()) {
        /// Searching supports only not empty strings
        guard !user.isEmpty else { completion(.finished, nil, UsersError.emptyUser); return }
        
        /// Prepare request data. Use `users/:username/repos` because Search API has limit for 1000 results and, for example, Google has more then 1000 repositories
        /// This implementation has no authorization and has limit to 60 requests per hour (authorization planned in next versions)
        guard var urlComponents = URLComponents(string: "https://api.github.com/search/users") else { completion(.finished, nil, UsersError.requestFormat); return }
        ///Max per_page value for `repos` request
        let perPage = 100
        var query = "q=\(user)+in:login&per_page=\(perPage)"
        if let accessToken = AppDelegate.shared.accessToken {
            query.append("&access_token=\(accessToken)")
        }
        urlComponents.query = query
        guard var searchingURL = urlComponents.url else { completion(.finished, nil, UsersError.requestFormat); return }

        
        /// Cancel previous searching
        searchingTask?.cancel()
        
        
        /// Create data task
        searchingTask = urlSession.dataTask(with: searchingURL) { data, response, error in
            
            /// Move code to main thread
            DispatchQueue.main.async {
                /// Defer for data task nullifying
                defer {
                    self.searchingTask = nil
                }
                
                if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200,
                    error == nil {
                    /// Valid response
                    
                    do {
                        let users: [User] = try self.objects(from: data)
                        completion(.finished, users, nil)
                    }  catch {
                        completion(.finished, nil, UsersError.responseFormat)
                    }
                    
                } else {
                    ///Not valid response
                    if let response = response as? HTTPURLResponse, response.statusCode == 401 {
                        completion(.finished, nil, UsersError.notAuthorized)
                    } else if let error = error, error._domain == NSURLErrorDomain, error._code == NSURLErrorCancelled {
                        completion(.cancelled, nil, error)
                    } else {
                        completion(.finished, nil, error ?? UsersError.requestFailed)
                    }
                }
            }
        }
        
        /// Resume data task
        searchingTask?.resume()
        
    }

    
}
