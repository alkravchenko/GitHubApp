//
//  UsersTableViewController.swift
//  GutHubApp
//
//  Created by Kravchenko on 31.01.2018.
//  Copyright © 2018 WaveAccess. All rights reserved.
//

import UIKit

class UsersTableViewController: UITableViewController {

    static let storyboardIdentifier = "Users"
    
    ///MARK: - Data
    
    /// Users
    var users = [User]()
    
    /// Handler for user selection
    var userDidSelect: ((_ user: User) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// To show dimmed backround until not empty `users`
        tableView.backgroundColor = .clear
        /// Don't show separators if table is empty
        tableView.tableFooterView = UIView(frame: .zero)

    }

    
}

// MARK: - Table view data source and delegate

/// Table view data source and delegate
extension UsersTableViewController {

    /// Number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        if users.isEmpty {
            return 1
        } else {
            return 1
        }
    }

    /// Number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    /// Cell for row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(.user, for: indexPath)
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.login
        
        return cell
    }
    
    /// Did select
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = users[indexPath.row]
        userDidSelect?(user)
    }

}
