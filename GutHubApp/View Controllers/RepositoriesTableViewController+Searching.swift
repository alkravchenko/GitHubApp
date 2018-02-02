//
//  RepositoriesTableViewController+UISearchBarDelegate.swift
//  GutHubApp
//
//  Created by Kravchenko on 02.02.2018.
//  Copyright © 2018 WaveAccess. All rights reserved.
//

import UIKit

//MARK: - Searching

/// Searching
extension RepositoriesTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        usersTableViewController.users.removeAll()
        usersTableViewController.tableView.reloadData()
        
        /// Start searching after 3 symbol
        guard searchText.count > 2 else { return }
        
        usersModelController.searchUsers(searchText) { result, users, error in
            switch result {
            case .finished:
                if let users = users, error == nil {
                    self.usersTableViewController.users = users
                    self.usersTableViewController.tableView.reloadData()
                } else {
                    //Do nothing
                }
                
                /// Authorize application if token expired
                if let error = error as? UsersModelController.UsersError, error == .notAuthorized {
                    AppDelegate.shared.authorize(from: self)
                }
                
            case .cancelled: break //Do nothing for `cancelled` result
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let userName = searchBar.text, !userName.isEmpty else {
            presentAlert(title: LocalizedString(.enterUserOrOwnerOrOrganizationTitle), message: "")
            return
        }
        self.searchController.isActive = false
        /// Prevent search bae emptying
        self.searchController.searchBar.text = userName
        searchRespositories(for: userName)
    }
    
    func searchRespositories(for userName: String) {
        guard !userName.isEmpty else {
            presentAlert(title: LocalizedString(.enterUserOrOwnerOrOrganizationTitle), message: "")
            return
        }
        
        usersTableViewController.users.removeAll()
        usersTableViewController.tableView.reloadData()
        
        if performFetchAndCheckHasRepositories(for: userName) {
            state = .searchingSuccess
        } else {
            state = .searchingInProgress
        }
        self.tableView.reloadData()
        
        repositoriesModelController.updateRepositories(for: userName) { result, error in
            switch result {
            case .finished:
                if error == nil {
                    self.state = .searchingSuccess
                } else {
                    if let error = error as? RepositoriesModelController.RepositoriesError, error == .userNotFound {
                        self.state = .searchingFailedBecauseUserNotFounded
                    } else {
                        if self.hasRepositories() {
                            self.state = .searchingSuccess
                        } else {
                            self.state = .searchingFailed
                        }
                    }
                    
                    /// Authorize application if token expired
                    if let error = error as? RepositoriesModelController.RepositoriesError, error == .notAuthorized {
                        AppDelegate.shared.authorize(from: self)
                    }
                    
                }
            case .cancelled: break //Do nothing for `cancelled` result
            }
            self.tableView.reloadData()
        }
        
    }
    
    /// Checks
    func hasRepositories() -> Bool {
        if let objects = fetchedResultsController.fetchedObjects, !objects.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    /// Call `fetchedResultsController.performFetch` and it can lead to content update
    func performFetchAndCheckHasRepositories(for userName: String) -> Bool {
        do {
            fetchRequest.predicate = NSPredicate(format: "\(#keyPath(Repository.ownerName)) CONTAINS[cd] %@", userName)
            try fetchedResultsController.performFetch()
            if let objects = fetchedResultsController.fetchedObjects, !objects.isEmpty {
                return true
            } else {
                return false
            }
        } catch {
            return false
        }
    }

    
}
