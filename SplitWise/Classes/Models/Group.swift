//
//  Group.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/25/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import UIKit
import RealmSwift
import RxDataSources

typealias GroupSection = AnimatableSectionModel<String,Group>

class Group: Object {
    @objc dynamic var uid: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var info: String?
    @objc dynamic var createdDate: Date = Date()
    let persons = List<Person>()
    override static func primaryKey() -> String? {
        return "uid"
    }
    static func create(name: String, info: String? = nil, realm: Realm) -> Group {
        let group = Group()
        group.name = name
        group.info = info
        group.createdDate = Date()
        group.uid = (realm.objects(Group.self).max(ofProperty: "uid") ?? 0) + 1
        return group
    }
}

extension Group : IdentifiableType {
    var identity: Int {
        return self.isInvalidated ? 0 : uid
    }
}
