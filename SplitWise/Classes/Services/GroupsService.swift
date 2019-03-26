//
//  GroupsService.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/25/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift

protocol GroupServiceType {
    @discardableResult
    func createGroup(name: String, description: String?) -> Observable<Group>

//    @discardableResult
//    func delete(group: Group) -> Observable<Void>
//
//    @discardableResult
//    func update(group: Group, title: String, description: String?) -> Observable<TaskItem>
//

    func groups() -> Observable<Results<Group>>
}

enum GroupServiceError: Error {
    case failedToCreateGroup(name: String?, description: String?)
}


struct GroupService: GroupServiceType {
    func groups() -> Observable<Results<Group>> {
        return PersistenceService.shared.objects(type: Group.self)
    }
    func createGroup(name: String, description: String?) -> Observable<Group> {
        let result = Observable<Group>.create({ (observer) -> Disposable in
            if let realm = PersistenceService.shared.realm {
                let group = Group.create(name: name, info: description, realm: realm)
                observer.onNext(group)
            } else {
                observer.onError(GroupServiceError.failedToCreateGroup(name: name, description: description))
            }
            observer.onCompleted()
            return Disposables.create()
        })
        return result.flatMap { (group) -> Observable<Group> in
            return PersistenceService.shared.create(object: group)
        }
    }

}
