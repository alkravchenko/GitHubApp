//
//  Repository+CoreDataClass.swift
//  GutHubApp
//
//  Created by Kravchenko on 30.01.2018.
//  Copyright © 2018 WaveAccess. All rights reserved.
//
//

import Foundation
import CoreData

/// `Respository` entity class
@objc(Repository)
public class Repository: NSManagedObject, Codable {
 
    /// Custom coding keys
    enum CodingKeys : String, CodingKey {
        case name
        case identifier = "id"
        case repositoryDescription = "description"
        case rating = "stargazers_count"
        case forksCount = "forksCount"
        case updatedAt = "updated_at"
        case language = "language"
        case owner
    }
    
    enum OwnerKeys : CodingKey {
        case login
    }
    
    /// Decoder
    required convenience public init(from decoder: Decoder) throws {
        guard let key = CodingUserInfoKey.managedObjectContext,
            let managedObjectContext = decoder.userInfo[key] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Repository", in: managedObjectContext) else {
                
                fatalError("Invalid configuration for `Repository` entity")
        }
        self.init(entity: entity, insertInto: nil)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.identifier = try container.decode(Int64.self, forKey: .identifier)
        self.repositoryDescription = try? container.decode(String.self, forKey: .repositoryDescription)
        self.rating = try? container.decode(Int64.self, forKey: .rating)
        self.forksCount = try? container.decode(Int64.self, forKey: .forksCount)
        self.updatedAt = try? container.decode(Date.self, forKey: .updatedAt)
        if let language = try? container.decode(String.self, forKey: .language) {
            self.language = language
        } else {
            self.language = LocalizedString(.other)
        }
        
        let nested = try container.nestedContainer(keyedBy: OwnerKeys.self, forKey: .owner)
        ownerName = try nested.decode(String.self, forKey: .login)
        
    }
    
    /// Update object from abother object
    func update(from object: Repository) {
        self.name = object.name
        self.identifier = object.identifier
        self.repositoryDescription = object.repositoryDescription
        self.rating = object.rating
        self.forksCount = object.forksCount
        self.updatedAt = object.updatedAt
        self.language = object.language
        self.ownerName = object.ownerName
    }
    
    /// Encoder
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(repositoryDescription, forKey: .repositoryDescription)
        try container.encode(rating, forKey: .rating)
        try container.encode(forksCount, forKey: .forksCount)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(language, forKey: .language)
        
        var nested = container.nestedContainer(keyedBy: OwnerKeys.self, forKey: .owner)
        try nested.encode(ownerName, forKey: .login)
    }
}


/// Custom `Repository` user info keys
extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}



