//
//  Localization.swift
//  GutHubApp
//
//  Created by Kravchenko on 27.01.2018.
//  Copyright © 2018 WaveAccess. All rights reserved.
//

import Foundation

//MARK: - Localization task helpers

///Localization function helper (add location constant support instead if plain strings)
func LocalizedString(_ key: LocalizationKey) -> String {
    return NSLocalizedString(key.rawValue, comment: "")
}

/// Loczalition constants enum
enum LocalizationKey: String {
    case ok = "OK"
    case userOrOwnerOrOrganizationPlaceholder = "UserOrOwnerOrOrganizationPlaceholder"
    case enterUserOrOwnerOrOrganizationTitle = "EnterUserOrOwnerOrOrganizationTitle"
    case searchingNotFoundTitle = "SearchingNotFoundTitle"
    case searchingFailedTitle = "SearchingFailedTitle"
    case searchingEmptyTitle = "SearchingEmptyTitle"
    case noName = "NoName"
    case noDescription = "NoDescription"
    case noRating = "NoRating"
    case noForks = "NoForks"
    case noUpdatedAtDate = "NoUpdatedAtDate"
    case stars = "Stars"
    case forks = "Forks"
    case updatedAt = "UpdatedAt"
    case other = "Other"
}
