//
//  Repositories.swift
//  GutHubApp
//
//  Created by Kravchenko on 27.01.2018.
//  Copyright © 2018 WaveAccess. All rights reserved.
//

import UIKit
import CoreData
import OAuth2

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

    /// Errors enum
    enum RepositoriesError: Error {
        case emptyUser
        case requestFormat
        case requestFailed
        case responseFormat
        case dataToObjectFailed
        case userNotFound
        case containerNotInitializaed
        case notAuthorized
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
    
    /// Helper for objects mapping
    func insertRepositories(from data: Data, to context: NSManagedObjectContext) throws {
        guard let _ = persistentContainer else { throw RepositoriesError.containerNotInitializaed }
        
        guard let jsonObjects = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { throw RepositoriesError.dataToObjectFailed }

        let decoder = JSONDecoder()
        
        guard let contextKey = CodingUserInfoKey.managedObjectContext else { fatalError("Incorrect application configuration") }
        
        decoder.userInfo[contextKey] = context
        decoder.dateDecodingStrategy = .iso8601
        let request: NSFetchRequest<Repository> = Repository.fetchRequest()
        
        for jsonObject in jsonObjects {
            guard let identifier = jsonObject["id"] as? Int64 else { throw RepositoriesError.dataToObjectFailed }
            
            let objectData = try JSONSerialization.data(withJSONObject: jsonObject)
            var repository = try decoder.decode(Repository.self, from: objectData)

            request.predicate = NSPredicate(format: "\(#keyPath(Repository.identifier)) = %@", identifier as NSNumber)
            let result = try managedObjectContext.fetch(request)

            if let alreadyExisitingObject = result.first {
                alreadyExisitingObject.update(from: repository)
                repository = alreadyExisitingObject
            } else {
                managedObjectContext.insert(repository)
            }
        }
    }
    
    func updateRepositories(from data: Data, in context: NSManagedObjectContext) throws {
        /// Precondition
        guard let _ = persistentContainer else { throw RepositoriesError.containerNotInitializaed }

        do {
            try self.insertRepositories(from: data, to: context)
        } catch {
            throw RepositoriesError.dataToObjectFailed
        }

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
    func updateRepositories(for user: String, completion: @escaping (_ result: SearchingResult, _ error: Error?) -> ()) {
        guard let persistentContainer = persistentContainer else { completion(.finished, RepositoriesError.containerNotInitializaed); return }

        /// Searching supports only not empty strings
        guard !user.isEmpty else { completion(.finished, RepositoriesError.emptyUser); return }


        var repositories = [Repository]()
        
        /// Prepare request data. Use `users/:username/repos` because Search API has limit for 1000 results and, for example, Google has more then 1000 repositories
        /// This implementation has no authorization and has limit to 60 requests per hour (authorization planned in next versions)
        guard var urlComponents = URLComponents(string: "https://api.github.com/users/\(user)/repos") else { completion(.finished, RepositoriesError.requestFormat); return }
        ///Max per_page value for `repos` request
        let perPage = 100
        var query = "per_page=\(perPage)"
        if let accessToken = AppDelegate.shared.accessToken {
            query.append("&access_token=\(accessToken)")
        }
        urlComponents.query = query
        guard var searchingURL = urlComponents.url else { completion(.finished, RepositoriesError.requestFormat); return }

        /// Managed object context and undo manager intitilization
        let managedObjectContext = persistentContainer.viewContext
        
        managedObjectContext.undoManager = UndoManager()
        managedObjectContext.undoManager?.beginUndoGrouping()

        let undoAndClearUndoManager = {
            managedObjectContext.undoManager?.endUndoGrouping()
            managedObjectContext.undoManager?.undo()
            managedObjectContext.undoManager = nil
        }

        let clearUndoManager = {
            managedObjectContext.undoManager?.endUndoGrouping()
            managedObjectContext.undoManager = nil
        }

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
                            try self.updateRepositories(from: data, in: managedObjectContext)
                            if let nextURL = self.nextRepositoriesPageURL(from: response) {
                                /// Go to next page
                                searchingURL = nextURL
                                goToNextRepositoriesPage()
                            } else {
                                /// All data fetched and can be saved
                                try managedObjectContext.save()
                                clearUndoManager()
                                completion(.finished, nil)
                            }
                        }  catch {
                            undoAndClearUndoManager()
                            completion(.finished, RepositoriesError.responseFormat)
                        }
                        
                    } else {
                        undoAndClearUndoManager()
                        ///Not valid response
                        
                        if let response = response as? HTTPURLResponse, response.statusCode == 404 {
                            /// User not found
                            completion(.finished, RepositoriesError.userNotFound)
                        } else if let response = response as? HTTPURLResponse, response.statusCode == 401 {
                            /// Access token was revoked
                            completion(.finished, RepositoriesError.notAuthorized)
                        } else if let error = error, error._domain == NSURLErrorDomain, error._code == NSURLErrorCancelled {
                            /// Request was revoked
                            completion(.cancelled, error)
                        } else {
                            /// Common error
                            completion(.finished, error ?? RepositoriesError.requestFailed)
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
    
    
    // MARK: - Core Data Srack
    
    /// Core Data Stack Initilization
    
    /// Managed object context
    var managedObjectContext: NSManagedObjectContext {
        /// Precondition
        guard let persistentContainer = persistentContainer else { fatalError("Context usage before core data stack initializartion") }

        return persistentContainer.viewContext
    }
    
    private var persistentContainer: NSPersistentContainer?
    
    func initialize(completion: @escaping (_ error: Error?) -> ()) {
        /// Precondition
        guard persistentContainer == nil else { completion(nil); return }
        
        /// Core Data container initizalition
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { storeDescription, error in
            if error == nil {
                self.persistentContainer = container
            }
            completion(error)
        }
    }
    
}
