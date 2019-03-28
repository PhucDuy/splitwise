//
//  Expanse.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/28/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import Foundation
import RealmSwift


class Expense: Object {
    @objc dynamic var uid: Int = 0
    @objc dynamic var title: String = ""
    @objc dynamic var createdDate: Date = Date()
    @objc dynamic var amount: Double = 0
    @objc dynamic var lender: Person?
    let group = LinkingObjects(fromType: Group.self, property: "expenses")
    let transactions = List<Transaction>()
    static func create(realm: Realm,
                       title: String,amount: Double,
        lender: Person,createdAt: Date,
        transactions: [TransactionData]) -> Expense {
        let expense = Expense()
        expense.uid = (realm.objects(Expense.self).max(ofProperty: "uid") ?? 0) + 1
        expense.createdDate = createdAt
        expense.title = title
        expense.amount = amount
        expense.lender = lender
        transactions.forEach { (data) in
            try? realm.write {
                if data.lendee.uid != lender.uid {
                    expense.transactions.append(Transaction.create(realm: realm, data: data, lender: lender))
                }
            }
        }
        return expense
    }
    override static func primaryKey() -> String? {
        return "uid"
    }

}
