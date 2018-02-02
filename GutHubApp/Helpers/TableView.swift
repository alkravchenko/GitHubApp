//
//  TableViewCells.swift
//  GutHubApp
//
//  Created by Kravchenko on 27.01.2018.
//  Copyright © 2018 WaveAccess. All rights reserved.
//

import UIKit

//MARK: - Helpers for table view

//MARK: - Enum for table view cell reuse identifiers

/// Enum for reuse identifiers
enum ReuseIdentifier: String {
    case repository = "Repository"
    case language = "Language"
    case user = "User"
}

//MARK: - Extension for dequeues family methods with constants instead of plain string

/// Extension for dequeues family methods with constants instead of plain string
extension UITableView {
    /// Dequeue reusable cell with identifier constant
    func dequeueReusableCell(_ identifier: ReuseIdentifier, for indexPath: IndexPath) -> UITableViewCell {
        return dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath)
    }
    /// Dequeue reusable header view with identifier constant
    func dequeueReusableHeaderFooterView(_ identifier: ReuseIdentifier) -> UITableViewHeaderFooterView {
        return dequeueReusableHeaderFooterView(withIdentifier: identifier.rawValue)!
    }
    /// Register class for header view with identifier constant
    func register(_ aClass: Swift.AnyClass?, forHeaderFooterViewReuseIdentifier identifier: ReuseIdentifier) {
        register(aClass, forHeaderFooterViewReuseIdentifier: identifier.rawValue)
    }
    /// Register class for cell with identifier constant
    func register(_ cellClass: Swift.AnyClass?, forCellReuseIdentifier identifier: ReuseIdentifier) {
        register(cellClass, forCellReuseIdentifier: identifier.rawValue)
    }
    
    
}
