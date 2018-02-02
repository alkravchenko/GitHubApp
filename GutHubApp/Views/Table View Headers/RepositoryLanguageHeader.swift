//
//  RepositoryLanguageHeader.swift
//  GutHubApp
//
//  Created by Kravchenko on 27.01.2018.
//  Copyright © 2018 WaveAccess. All rights reserved.
//

import UIKit

class RepositoryLanguageHeader: UITableViewHeaderFooterView {
    
    /// Customize header appearance
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        textLabel?.textColor = .darkGray
        contentView.backgroundColor = UIColor(red: 246.0/255.0, green: 246.0/255.0, blue: 246.0/255.0, alpha: 1.0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = nil
    }
}
