//
//  StoreService.swift
//
//  Created by Matviy Suk on 23.03.2022.
//

import Foundation
import FirebaseFirestore

enum CollectionType: String {
    case generalNotifications = "general_notifications/"
    case XXXs = "XXXs/"
    case reports = "reports/"
    case userNotifications = "user_notifications/"
    case userPreferences = "user_preferences/"
}

enum DocumentRoute {
    case report(id: String)
    case XXX(id: String)
}

enum CollectionRoute {
    case generalNotifications
    case XXXs
    case reports
    case userNotifications
    case userPreferences
}

protocol StoreService: AnyObject {

    // MARK: - Configuration

    func configure()
    
    func collectionReference(
        to route: CollectionRoute
    ) -> CollectionReference
    
    func documentReference(
        to route: DocumentRoute
    ) -> DocumentReference
    
    // MARK: - Appearance
    
}


