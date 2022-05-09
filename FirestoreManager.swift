//
//  FirestoreManager.swift
//
//  Created by Matviy Suk on 25.03.2022.
//

import FirebaseFirestoreSwift
import Firebase
import GeoFireUtils

struct FirestoreManager {
    static func getAllXXXs(completion: @escaping DefaultResultCallback<[XXX]>) {
        let collRef = App.storeService.collectionReference(to: .XXXs)

        collRef.getDocuments { snapshot, error in
            switch fetchDocuments(for: XXXResponseContent.self, snapshot, error) {
            case .success(let XXXs):
                completion(.success(XXXs.map { $0.context }))
                break
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func getXXX(
        by id: String,
        completion: @escaping DefaultResultCallback<XXX>
    ) {
        let docRef = App.storeService.documentReference(to: .XXX(id: id))

        docRef.getDocument { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                if let error = error {
                    completion(.failure(error))
                }

                return
            }

            do {
                let XXX = try snapshot.data(as: XXXResponseContent.self)
                
                completion(.success(XXX.context))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    static func getReportsForXXX(
        by id: String,
        completion: @escaping DefaultResultCallback<[Report]>
    ) {
        let collRef = App.storeService.collectionReference(to: .reports)
        
        collRef
            .whereField(Report.CodingKeys.XXXId.stringValue, isEqualTo: id)
            .getDocuments { snapshot, error in
                switch fetchDocuments(for: ReportResponseContent.self, snapshot, error) {
                case .success(let reports):
                    completion(.success(reports.filter {
                        $0.status == ReportStatus.approved.rawValue
                    }.map { $0.context } ))
                    break
                case .failure(let error):
                    completion(.failure(error))
                    break
                }
            }
    }
    
    
    // MARK: - Reports
    static func getAllReports(withStatus: ReportStatus, completion: @escaping DefaultResultCallback<[Report]>) {
        let collRef = App.storeService.collectionReference(to: .reports)

        collRef.getDocuments { snapshot, error in
            switch fetchDocuments(for: ReportResponseContent.self, snapshot, error) {
            case .success(let reports):
                completion(.success(reports.map { $0.context }))
                break
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    static func createReport(parameters: [String: Any]) {
        let db = Firestore.firestore()
        
        db.collection(CollectionType.reports.rawValue).addDocument(data: parameters) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }

    static func getReportsForUser(_ id: String, completion: @escaping DefaultResultCallback<[Report]>) {
        let collRef = App.storeService.collectionReference(to: .reports)
        
        collRef
            .whereField(Report.CodingKeys.userId.stringValue, isEqualTo: id)
            .getDocuments { snapshot, error in
                switch fetchDocuments(for: ReportResponseContent.self, snapshot, error) {
                case .success(let reports):
                    completion(.success(reports.map { $0.context }))
                    break
                case .failure(let error):
                    completion(.failure(error))
                    break
                }
            }
    }
    
    static func setPreferencesForUser(
        _ prefers: UserPreferences,
        completion: @escaping EmptyClosure
    ) {
        let collRef = App.storeService.collectionReference(to: .userPreferences)
                
        collRef.document(prefers.userId).setData(prefers.dictionaryRepresentation()) { error in
            if let error = error {
                print("Unable to create User Preferences document: \(error)")
            }
            
            completion()
        }
    }
    
    static func getPreferencesForUser(
        _ id: String,
        completion: @escaping DefaultResultCallback<UserPreferences>
    ) {
        let collRef = App.storeService.collectionReference(to: .userPreferences)
        
        collRef.document(id).getDocument { snapshot, error in
            completion(fetchDocument(for: UserPreferences.self, snapshot, error))
        }
    }
}

fileprivate func fetchDocument<T: Decodable>(
    for type: T.Type,
    _ snapshot: DocumentSnapshot?,
    _ error: Error?
) -> Result<T, Error> {
    let defaultError = StringError("Unable to fetch the document")
    
    guard let snapshot = snapshot, error == nil else {
        return .failure(error ?? defaultError)
    }
    
    do {
        let item = try snapshot.data(as: type.self)
        
        return .success(item)
    } catch {
        return .failure(error)
    }
}

fileprivate func fetchDocuments<T: Decodable>(
    for type: T.Type,
    _ snapshot: QuerySnapshot?,
    _ error: Error?
) -> Result<[T], Error> {
    let defaultError = StringError("Unable to fetch the documents")
    
    guard let snapshot = snapshot, error == nil else {
        return .failure(error ?? defaultError)
    }
    
    do {
        if let items = try decodeQuerySnapshot(snapshot, to: type.self) {
            return .success(items)
        }
    } catch {
        return .failure(error)
    }
    
    return .failure(defaultError)
}

fileprivate func decodeQuerySnapshot<T: Decodable>(
    _ snapshot: QuerySnapshot,
    to object: T.Type
) throws -> [T]? {
    var data: [T] = []

    for document in snapshot.documents {
        do {
            let element = try document.data(as: object.self)
            
            data.append(element)
        } catch {
            print(error)
            continue
        }
    }
    
    return data
}
