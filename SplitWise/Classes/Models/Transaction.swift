//
//  Transaction.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/28/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import Foundation
import RealmSwift

struct TransactionData {
    var lendee: Person?
    var amount: Double
}


class Transaction: Object {
    @objc dynamic var createdDate: Date = Date()
    @objc dynamic var lendee: Person?
    @objc dynamic var lender: Person?
    @objc dynamic var amount: Double = 0
    let expense = LinkingObjects(fromType: Expense.self, property: "transactions")
    static func create(realm: Realm, data: TransactionData, lender: Person) -> Transaction {
        let transaction = Transaction()
        transaction.lender = lender
        transaction.lendee = data.lendee
        transaction.amount = data.amount
        return transaction
    }
    func toData() -> TransactionData {
        return TransactionData(lendee: self.lendee, amount: self.amount)
    }
}
