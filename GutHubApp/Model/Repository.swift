//
//  Repository.swift
//  GutHubApp
//
//  Created by Kravchenko on 27.01.2018.
//  Copyright © 2018 WaveAccess. All rights reserved.
//

import Foundation

//MARK: - Repository model implementation

/// `Respository` entity class
class Repository: Codable {
    let name: String?
    let repositoryDescription: String?
    let rating: Int?
    let forksCount: Int?
    let updatedAt: Date?
    let language: String?
    
    /// Special sproperty for grouping
    var languageForGrouping: String {
        /// If repository has no `language` then use custom `Other` group
        return language ?? LocalizedString(.other)
    }

    ///Special property for sorting
    var ratingForSorting: Int {
        /// `-1` value for `Other` group
        return rating ?? -1
    }

    init(name: String?, repositoryDescription: String?, rating: Int?, forksCount: Int?, updatedAt: Date?, language: String?) {
        self.name = name
        self.repositoryDescription = repositoryDescription
        self.rating = rating
        self.forksCount = forksCount
        self.updatedAt = updatedAt
        self.language = language
    }
    
    /// Custom mapping
    enum CodingKeys : String, CodingKey {
        case name = "name"
        case repositoryDescription = "description"
        case rating = "stargazers_count"
        case forksCount = "forksCount"
        case updatedAt = "updated_at"
        case language = "language"
    }
}
