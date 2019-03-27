//
//  MemberService.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/26/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

protocol MemberServiceType {
    @discardableResult
    func createPerson(name: String, group: Group) -> Observable<Person>
}

enum MemberServiceError: Error {
    case failedToCreatePerson(name: String, group: Group)
}


struct MemberService: MemberServiceType {
    func createPerson(name: String, group: Group) -> Observable<Person> {
        let result = PersistenceService.shared.withRealm("create Person", action: { (realm) -> Observable<Person> in
            let member = Person.createPerson(name: name, realm: realm)
            try realm.write {
                group.members.append(member)
            }
            return .just(member)
        })
        return result ?? .error(MemberServiceError.failedToCreatePerson(name: name,
                                                                        group: group))

    }

}
