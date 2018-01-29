//
//  Repositories.swift
//  GutHubApp
//
//  Created by Kravchenko on 27.01.2018.
//  Copyright © 2018 WaveAccess. All rights reserved.
//

import UIKit

//MARK: - Protocol-oriented implementation of Repositories model controller functionality

//MARK: -

/// Protocol for `Repositories` model controller clients (implicity adds `repositoriesModelController` property to class)
protocol Repositories: AnyObject {
    /// Property for access to Repositories model controller functionality
    var repositoriesModelController: RepositoriesModelController { get }
}

/// Protocol extension for `UIViewController` (add `repositoriesModelController` implementation), other classes requires its own implementation
extension Repositories where Self: UIViewController {
    /// Property for access to `Repositorie`s model controller functionality
    var repositoriesModelController: RepositoriesModelController {
        return RepositoriesModelController.shared
    }
}

//MARK: - Repositories model controller

/// `Repositories` model controller
class RepositoriesModelController {
    /// Shared `Repositories model` controller object (singleton). Can not be accesses outside this file (for preventing code connectivity problems). You shoul access to this property only via `Respository` protocol implementation.
    fileprivate static let shared = RepositoriesModelController()

    /// Error enum
    enum RepositoriesError: Error {
        case emptyUser
        case requestFormat
        case requestFailed
        case responseFormat
        case dataToObjectFailed
        case userNotFound
    }
    
    /// Session for searching requests
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
    
    /// Result enum
    enum SearchingResult {
        case finished
        case cancelled
    }
    
    /// Helper for objects mapping
    func objects<T>(from data: Data) throws -> [T] where T : Decodable {
        guard let jsonObjects = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { throw RepositoriesError.dataToObjectFailed }

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
    
    /// Helper for get link headers
    func nextRepositoriesPageURL(from response: HTTPURLResponse) -> URL? {
        guard let link = response.allHeaderFields["Link"] as? String else { return nil }
           
        let links = link.components(separatedBy: ", ")
        for link in links {
            let components = link.components(separatedBy: "; ")
            if var urlString = components.first,
                let type = components.last,
                type == "rel=\"next\"" {
                
                urlString = String(urlString.dropFirst())
                urlString = String(urlString.dropLast())
                
                if let nextURL = URL(string: urlString) {
                    return nextURL
                }
            }
        }
        return nil
    }
    
    /// Method for repositories searching
    func searchRepositories(for user: String, completion: @escaping (_ result: SearchingResult, _ repositories: [Repository]?, _ error: Error?) -> ()) {
        /// Searching supports only not empty strings
        guard !user.isEmpty else { completion(.finished, nil, RepositoriesError.emptyUser); return }

        var repositories = [Repository]()

        /// Prepare request data. Use `users/:username/repos` because Search API has limit for 1000 results and, for example, Google has more then 1000 repositories
        /// This implementation has no authorization and has limit to 60 requests per hour (authorization planned in next versions)
        guard var urlComponents = URLComponents(string: "https://api.github.com/users/\(user)/repos") else { completion(.finished, nil, RepositoriesError.requestFormat); return }
        ///Max per_page value for `repos` request
        let perPage = 100
        var query = "per_page=\(perPage)"
        urlComponents.query = query
        guard var searchingURL = urlComponents.url else { completion(.finished, nil, RepositoriesError.requestFormat); return }

        /// Recursive solution for pagination
        func goToNextRepositoriesPage() {
        
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
                            let responseRepositories: [Repository] = try self.objects(from: data)
                            repositories.append(contentsOf: responseRepositories)
                            if let nextURL = self.nextRepositoriesPageURL(from: response) {
                                searchingURL = nextURL
                                goToNextRepositoriesPage()
                            } else {
                                completion(.finished, repositories, nil)
                            }
                        }  catch {
                            completion(.finished, nil, RepositoriesError.responseFormat)
                        }
                        
                    } else {
                        ///Not valid response
                        if let response = response as? HTTPURLResponse, response.statusCode == 404 {
                            completion(.finished, nil, RepositoriesError.userNotFound)
                        } else {
                            if let error = error, error._domain == NSURLErrorDomain, error._code == NSURLErrorCancelled {
                                completion(.cancelled, nil, error)
                            } else {
                                completion(.finished, nil, error ?? RepositoriesError.requestFailed)
                            }
                        }
                    }
                }
            }
            
            /// Resume data task
            searchingTask?.resume()
        }
        /// First repositories page processing
        goToNextRepositoriesPage()

    }
}
