//
//  RepositoriesTableViewController+NSFetchedResultsControllerDelegate.swift
//  GutHubApp
//
//  Created by Kravchenko on 02.02.2018.
//  Copyright © 2018 WaveAccess. All rights reserved.
//

import CoreData

//MARK: - NSFetchedResultsControllerDelegate

/// NSFetchedResultsControllerDelegate
extension RepositoriesTableViewController: NSFetchedResultsControllerDelegate {
    /// Context has changes and we should reload table view
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
