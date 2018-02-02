//
//  RespositoriesTableViewController+TableView.swift
//  GutHubApp
//
//  Created by Kravchenko on 02.02.2018.
//  Copyright © 2018 WaveAccess. All rights reserved.
//

import UIKit

// MARK: - Repositories Table view data source/delegate

/// Repositories Table view data source/delegate
extension RepositoriesTableViewController {
    
    /// Number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        self.stopAllActivities()
        switch state {
        case .searchNotPerformedYet:
            showLabel(text: LocalizedString(.enterUserOrOwnerOrOrganizationTitle))
            return 0
        case .searchingInProgress:
            startActivityIndicator()
            return 0
        case .searchingSuccess:
            guard let numberOfSections = fetchedResultsController.sections?.count else { fatalError("Data and UI not synchronized") }
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
            guard let numberOfRows = fetchedResultsController.sections?[section].objects?.count  else { fatalError("Data and UI not synchronized") }
            precondition(numberOfRows > 0, "Number of sections for `searchingSuccess` state should be equal to 1 only with no empty `repositories`")
            return numberOfRows
        case .searchingInProgress,
             .searchNotPerformedYet,
             .searchingFailedBecauseUserNotFounded,
             .searchingFailed: fatalError("Number of sections for state should be equal to 0")
        }
    }
    
    
    //Configure repository table view cell
    func configureRepositoryCell(_ cell: RepositoryTableViewCell, at indexPath: IndexPath) {
        let repository = fetchedResultsController.object(at: indexPath)
        
        cell.nameTitle.text = repository.name
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
        guard let firstRepositoryInSection = fetchedResultsController.sections?[section].objects?.first as? Repository else { fatalError("Data and UI not synchronized") }
        
        header.textLabel?.text = firstRepositoryInSection.language
        
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




