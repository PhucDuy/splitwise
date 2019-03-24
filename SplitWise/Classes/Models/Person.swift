//
//  Person.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/24/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import UIKit
import RealmSwift

class Person: Object {
    @objc dynamic var uid: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var createdDate: Date = Date()
    static func createPerson(name: String, realm: Realm) -> Person {
        let person = Person()
        person.name = name
        person.createdDate = Date()
        person.uid = (realm.objects(Person.self).max(ofProperty: "uid") ?? 0) + 1
        return person
    }
    override static func primaryKey() -> String? {
        return "uid"
    }
    override static func indexedProperties() -> [String] {
        return ["name"]
    }
}
