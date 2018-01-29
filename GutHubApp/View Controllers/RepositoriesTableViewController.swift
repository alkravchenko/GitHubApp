//
//  RepositoriesTableViewController.swift
//  GutHubApp
//
//  Created by Kravchenko on 27.01.2018.
//  Copyright © 2018 WaveAccess. All rights reserved.
//

import UIKit

//MARK: - Respositories table view controller base implementation

/// Repositories table view controller (according to protocol-oriented approach it applies `Repositories` and `SearchingActivity` protocols)
class RepositoriesTableViewController: UITableViewController, Repositories, SearchingActivity, Alerts {

    //MARK: Data
    
    /// State machine enums
    enum State {
        case searchNotPerformedYet
        case searchingSuccess
        case searchingFailedBecauseUserNotFounded
        case searchingFailed
    }
    
    /// Property for current state (State Machine)
    private(set) var state: State = .searchNotPerformedYet
    
    /// Sorted and grouped repositories
    private(set) var repositories = [String: [Repository]]()
    
    /// Sorted languages for table view configuration. Should be updated via `resortLanguages`
    private(set) var sortedLanguages = [String]()
    
    /// Resort languages for table view
    private func resortLanguages() {
        sortedLanguages = repositories.keys.sorted()
    }
    
    /// Helper for get repository for `indexPath`
    func repositoryFor(_ indexPath: IndexPath) -> Repository {
        let repositories = repositoriesIn(indexPath.section)
        let repository = repositories[indexPath.row]
        return repository
    }

    /// Helper for get repositories array for `section`
    func repositoriesIn(_ section: Int) -> [Repository] {
        guard let repositories = repositories[sortedLanguages[section]] else { fatalError("UI and data not synchronized") }
        return repositories
    }
    
    /// Date formatter for `updatedAt` label in cells
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    //MARK: View lyfecycle

    /// Search controller
    let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = LocalizedString(.userOrOwnerOrOrganizationPlaceholder)
        searchController.searchBar.autocapitalizationType = .sentences
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        if #available(iOS 11.0, *) {
            //Do nothing
        } else {
           searchController.searchBar.searchBarStyle = .minimal
        }
        return searchController
    }()
    
    /// Configure search controller
    func configureSearchController() {
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController;
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            navigationItem.titleView = searchController.searchBar
        }
        searchController.searchBar.delegate = self
    }
    
    
    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Configure search controller
        configureSearchController()
        /// Register language header
        tableView.register(RepositoryLanguageHeader.self, forHeaderFooterViewReuseIdentifier: ReuseIdentifier.language)
        /// Don't show separators if table is empty
        tableView.tableFooterView = UIView(frame: .zero)
    }


}


// MARK: - Repositories Table view data source/delegate

/// Repositories Table view data source/delegate
extension RepositoriesTableViewController {
    
    /// Number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        switch state {
        case .searchNotPerformedYet:
            showLabel(text: LocalizedString(.enterUserOrOwnerOrOrganizationTitle))
            return 0
        case .searchingSuccess:
            let numberOfSections = sortedLanguages.count
            if numberOfSections > 0 {
                return numberOfSections
            } else {
                showLabel(text: LocalizedString(.searchingEmptyTitle))
                return 0
            }
        case .searchingFailedBecauseUserNotFounded:
            showLabel(text: LocalizedString(.searchingNotFoundTitle))
            return 0
        case .searchingFailed:
            showLabel(text: LocalizedString(.searchingFailedTitle))
            return 0
        }
    }
    
    /// Number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch state {
        case .searchingSuccess:
            let numberOfRows = repositoriesIn(section).count
            precondition(numberOfRows > 0, "Number of sections for `searchingSuccess` state should be equal to 1 only with no empty `repositories`")
            return numberOfRows
        case .searchNotPerformedYet, .searchingFailedBecauseUserNotFounded, .searchingFailed: fatalError("Number of sections for state should be equal to 0")
        }
    }
    
    
    //Configure repository table view cell
    func configureRepositoryCell(_ cell: RepositoryTableViewCell, at indexPath: IndexPath) {
        let repository = repositoryFor(indexPath)
        
        cell.nameTitle.text = repository.name ?? LocalizedString(.noName)
        cell.descriptionTitle.text = repository.repositoryDescription ?? LocalizedString(.noDescription)
        
        if let forksCount = repository.forksCount {
            cell.forksCountTitle.text = LocalizedString(.forks) + "\(forksCount)"
        } else {
            cell.forksCountTitle.text = LocalizedString(.forks) + LocalizedString(.noForks)
        }

        if let rating = repository.rating {
            cell.ratingTitle.text = LocalizedString(.stars) + "\(rating)"
        } else {
            cell.ratingTitle.text = LocalizedString(.stars) + LocalizedString(.noRating)
        }

        if let updatedAtDate = repository.updatedAt {
            let updatedAtDateString = dateFormatter.string(from: updatedAtDate)
            cell.updatedAtTitle.text = LocalizedString(.updatedAt) + updatedAtDateString
        } else {
            cell.updatedAtTitle.text = LocalizedString(.updatedAt) + LocalizedString(.noRating)
        }

    }
    
    /// Cell for row at index path
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(.repository, for: indexPath) as? RepositoryTableViewCell else { fatalError("Unsupported table view cell subclass") }
        
        configureRepositoryCell(cell, at: indexPath)
         
        return cell
     }
    
    
    /// Configure table header
    func configureLanguageHeader(_ header: RepositoryLanguageHeader, in section: Int) {

        header.textLabel?.text = sortedLanguages[section]

    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(.language) as? RepositoryLanguageHeader else { fatalError("Unsupported table header subclass") }
        configureLanguageHeader(header, in: section)
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
}

//MARK: - Search bar delegate

/// Search bar delegate
extension RepositoriesTableViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let user = searchBar.text, !user.isEmpty else {
            presentAlert(title: LocalizedString(.enterUserOrOwnerOrOrganizationTitle), message: "")
            return
        }
        /// Remove all repositories
        repositories.removeAll()
        resortLanguages()
        self.tableView.reloadData()

        startActivityIndicator()
        repositoriesModelController.searchRepositories(for: user) { result, repositories, error in
            if result == .finished {
                if let repositories = repositories, error == nil {
                    self.state = .searchingSuccess
                    let sortedRepositories = repositories.sorted { $0.ratingForSorting >= $1.ratingForSorting }
                    self.repositories = Dictionary(grouping: sortedRepositories) { $0.languageForGrouping }
                    self.resortLanguages()
                } else {
                    if let error = error as? RepositoriesModelController.RepositoriesError, error == .userNotFound {
                        self.state = .searchingFailedBecauseUserNotFounded
                    } else {
                        self.state = .searchingFailed
                    }
                }
            } else {
                //Do nothing for `cancelled` result
            }
            self.stopAllActivities()
            self.tableView.reloadData()
        }
    }
    
}
