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
    fileprivate func withRealm<T>(_ operation: String, action: (Realm) throws -> T) -> T? {
        do {
            let realm = try Realm()
            return try action(realm)
        } catch let err {
            print("Failed \(operation) realm with error: \(err)")
            return nil
        }
    }

}

