//
//  FirestoreService.swift
//
//  Created by Matviy Suk on 23.03.2022.
//

import Foundation
import FirebaseFirestore

final class FirestoreService: StoreService {
    // MARK: - Properties
    private lazy var db = Firestore.firestore()
    private var connectionId: String?
    
    // MARK: - Configuration
    func configure() {
        
    }
    
    func collectionReference(to route: CollectionRoute) -> CollectionReference {
        switch route {
        case .generalNotifications:
            return db.reference(to: .generalNotifications)
        case .XXXs:
            return db.reference(to: .XXXs)
        case .reports:
            return db.reference(to: .reports)
        case .userNotifications:
            return db.reference(to: .userNotifications)
        case .userPreferences:
            return db.reference(to: .userPreferences)
        }
    }
    
    func documentReference(to route: DocumentRoute) -> DocumentReference {
        switch route {
        case .report(id: let reportId):
            return collectionReference(to: .reports).document(reportId)
        case .XXX(id: let XXXId):
            return collectionReference(to: .XXXs).document(XXXId)
        }
    }
}

extension Firestore {
    func reference(
        to route: CollectionType
    ) -> CollectionReference {
        collection(route.rawValue)
    }
}

extension DocumentReference {
    func reference(
        to route: CollectionType
    ) -> CollectionReference {
        collection(route.rawValue)
    }
}
