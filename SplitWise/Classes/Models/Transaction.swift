//
//  Transaction.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/28/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import Foundation
import RealmSwift

enum AggregateStatus {
    case none
    case sameLenderAndLendee
    case lenderIsLendee
    case sameLenderDifferentLendee
    case sameLendeeDifferentLender
}

struct TransactionData {
    var lender: Person?
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
        return TransactionData(lender: lender, lendee: self.lendee, amount: self.amount)
    }

}
