//
//  RepositoryTableViewCell.swift
//  GutHubApp
//
//  Created by Kravchenko on 27.01.2018.
//  Copyright © 2018 WaveAccess. All rights reserved.
//

import UIKit

class RepositoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameTitle: UILabel!
    @IBOutlet weak var descriptionTitle: UILabel!
    @IBOutlet weak var ratingTitle: UILabel!
    @IBOutlet weak var forksCountTitle: UILabel!
    @IBOutlet weak var updatedAtTitle: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameTitle.text = nil
        descriptionTitle.text = nil
        ratingTitle.text = nil
        forksCountTitle.text = nil
        updatedAtTitle.text = nil
    }
    


}
