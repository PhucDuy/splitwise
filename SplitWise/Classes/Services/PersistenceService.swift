//
//  PersistenceService.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/24/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift
import RxRealm

enum PersistenceServiceError: Error {
    case createPersonPersonFailed(person: Person)
    case failedToCreate(object: Object)
    case failedToUpdate(object: Object)
}


class PersistenceService: NSObject {
    // MARK: - Singleton
    static let shared = PersistenceService()
    var realm: Realm? {
        let realm = try? Realm()
        return realm
    }
    func autoMigration() {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 1,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        _ = try? Realm()
    }
    // MARK: - Public
    func create<T>(object: T) -> Observable<T> where T: Object {
        let result = withRealm("Create") {
            (realm) -> Observable<T> in
            try realm.write {
                realm.add(object, update: false)
            }
            return .just(object)
        }
        return result ?? .error(PersistenceServiceError.failedToCreate(object: object))
    }
    func update<T>(object: T) -> Observable<T> where T: Object {
        let result = withRealm("Create") {
            (realm) -> Observable<T> in
            try realm.write {
                realm.add(object, update: true)
            }

            return .just(object)
        }
        return result ?? .error(PersistenceServiceError.failedToUpdate(object: object))
    }
    func delete<T>(object: T) -> Observable<T> where T: Object {
        let result = withRealm("Create") {
            (realm) -> Observable<T> in
            if !object.isInvalidated {
                try realm.write {
                    realm.delete(object)
                }
            }

            return .just(object)
        }
        return result ?? .error(PersistenceServiceError.failedToUpdate(object: object))
    }
    func objects<T>(type: T.Type) -> Observable<Results<T>> where T: Object {
        let result = withRealm("get objects", action: { (realm) -> Observable<Results<T>> in
            let realm = try Realm()
            let objects = realm.objects(type)
            return Observable.collection(from: objects)
        })
        return result ?? .empty()
    }
    
    // MARK: - Private
    func withRealm<T>(_ operation: String, action: (Realm) throws -> T) -> T? {
        do {
            let realm = try Realm()
            return try action(realm)
        } catch let err {
            print("Failed \(operation) realm with error: \(err)")
            return nil
        }
    }

}

