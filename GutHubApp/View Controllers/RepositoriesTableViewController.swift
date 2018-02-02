//
//  RepositoriesTableViewController.swift
//  GutHubApp
//
//  Created by Kravchenko on 27.01.2018.
//  Copyright © 2018 WaveAccess. All rights reserved.
//

import UIKit
import CoreData

//MARK: - Respositories table view controller base implementation

/// Repositories table view controller (according to protocol-oriented approach it applies `Repositories` and `SearchingActivity` protocols)
class RepositoriesTableViewController: UITableViewController, Repositories, Users, SearchingActivity, Alerts {
    

    //MARK: Core Data
    
    let fetchRequest: NSFetchRequest<Repository> = {
        let request: NSFetchRequest<Repository> = Repository.fetchRequest()
        /// String keypath because of compiler error for Core Data ObjC types but we have custom implementation for this attributes and it is correct behaviour
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Repository.language), ascending: true),
                                   NSSortDescriptor(key: "rating", ascending: false)]
        return request
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController<Repository> = {
        let resultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                           managedObjectContext: repositoriesModelController.managedObjectContext,
                                                           sectionNameKeyPath: #keyPath(Repository.language),
                                                           cacheName: nil)
        resultsController.delegate = self
        return resultsController
    }()

    
    /// State machine enums
    enum State {
        case searchNotPerformedYet
        case searchingInProgress
        case searchingSuccess
        case searchingFailedBecauseUserNotFounded
        case searchingFailed
    }
    
    /// Property for current state (State Machine)
    var state: State = .searchNotPerformedYet
    
    /// Date formatter for `updatedAt` label in cells
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    //MARK: View lyfecycle

    /// Search controller (constant imitation via implicity unwrapped optional because first intialization in viewDidLoad method)
    var searchController: UISearchController!
    /// Search Results controller(constant imitation via implicity unwrapped optional because first intialization in viewDidLoad method)
    var usersTableViewController: UsersTableViewController!

    /// Configure search controller
    func configureSearchController() {
        
        guard let usersTableViewController = self.storyboard?.instantiateViewController(withIdentifier: UsersTableViewController.storyboardIdentifier) as? UsersTableViewController else { fatalError("Invalid application configuration") }
        
        self.usersTableViewController = usersTableViewController
        
        searchController = UISearchController(searchResultsController: usersTableViewController)
        searchController.searchBar.placeholder = LocalizedString(.userOrOwnerOrOrganizationPlaceholder)
        searchController.searchBar.autocapitalizationType = .sentences
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true//false
        definesPresentationContext = true

        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController;
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            searchController.searchBar.searchBarStyle = .minimal

            navigationItem.titleView = searchController.searchBar
        }
        searchController.searchBar.delegate = self
        
        self.usersTableViewController.userDidSelect = { user in
            self.searchController.searchBar.text = user.login
            self.searchController.isActive = false
            /// Prevent search bae emptying
            self.searchController.searchBar.text = user.login
            self.searchRespositories(for: user.login)
        }

    }
    
    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        repositoriesModelController.initialize { error in
            if error != nil {
                self.presentAlert(title: LocalizedString(.modelInitizalitionErrorTitle), message: LocalizedString(.modelInitizalitionErrorMessage))
            }
        }
        /// Configure search controller
        configureSearchController()
        /// Register language header
        tableView.register(RepositoryLanguageHeader.self, forHeaderFooterViewReuseIdentifier: ReuseIdentifier.language)
        /// Don't show separators if table is empty
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    private(set) var isFirstAppearing = true

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /// GutHub authorization if needed
        if isFirstAppearing,
            AppDelegate.shared.accessToken == nil {
            
            AppDelegate.shared.authorize(from: self)
        }
        isFirstAppearing = false
    }
    
}


