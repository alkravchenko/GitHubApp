//
//  UIViewController+Alerts.swift
//  GutHubApp
//
//  Created by Kravchenko on 28.01.2018.
//  Copyright © 2018 WaveAccess. All rights reserved.
//

import UIKit

//MARK: - Helpers for alerts showing

/// Protocol for add alerts capabilities to view controller
protocol Alerts: AnyObject {
    func presentAlert(title: String, message: String)
}

/// Extension to add default implementation of `Alerts` to view controller
extension Alerts where Self: UIViewController {
    func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: LocalizedString(.ok), style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
