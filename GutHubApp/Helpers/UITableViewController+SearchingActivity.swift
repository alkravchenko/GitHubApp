//
//  UITableViewController+Activity.swift
//  GutHubApp
//
//  Created by Kravchenko on 27.01.2018.
//  Copyright © 2018 WaveAccess. All rights reserved.
//

import UIKit


//MARK: - Helpers for searching in table view controller

/// Protocol for adding activity functionality while searching
protocol SearchingActivity: AnyObject {
    func startActivityIndicator()
    func stopActivityIndicator()
    func showLabel(text: String)
    func hideLabel()
    func stopAllActivities()
}


private let labelTag = 2
private let activityTag = 1

/// Protocol extension with default `SearchingActivity` implementation for table view controller (Protocol-oriented approach)
extension SearchingActivity where Self: UITableViewController {
    /// Start activity indicator inside table
    func startActivityIndicator() {
        stopAllActivities()
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.color = .black
        activityIndicator.tag = activityTag
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        tableView.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        var constant: CGFloat = 0
        if let navigationBar = navigationController?.navigationBar {
            constant = navigationBar.bounds.size.height
        }
        activityIndicator.centerYAnchor.constraint(equalTo: tableView.centerYAnchor, constant: -constant).isActive = true
        activityIndicator.startAnimating()
    }
    
    /// Stop activity indicator inside table
    func stopActivityIndicator() {
        if let activityIndicator = tableView.viewWithTag(activityTag) as? UIActivityIndicatorView {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
    
    /// Show label inside table
    func showLabel(text: String) {
        stopActivityIndicator()
        hideLabel()
        let label = UILabel()
        label.text = text
        label.textColor = .black
        label.tag = labelTag
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        tableView.addSubview(label)
        label.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        var constant: CGFloat = 0
        if let navigationBar = navigationController?.navigationBar {
            constant = navigationBar.bounds.size.height
        }
        label.centerYAnchor.constraint(equalTo: tableView.centerYAnchor, constant: -constant).isActive = true
        
    }
    
    /// Hide label inside table
    func hideLabel() {
        if let label = tableView.viewWithTag(labelTag) as? UILabel {
            label.removeFromSuperview()
        }
    }
    
    /// Hide all custom activity views from table
    func stopAllActivities() {
        stopActivityIndicator()
        hideLabel()
    }
}
