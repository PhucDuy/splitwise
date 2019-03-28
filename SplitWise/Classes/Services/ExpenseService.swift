//
//  ExpenseService.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/28/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

protocol ExpenseServiceType {
    @discardableResult
    func createExpense(title: String,amount: Double,
        lender: Person,
        createdAt: Date,
        transactions: [TransactionData],
        group: Group) -> Observable<Expense>

}
enum ExpenseServiceError: Error {
    case failedToValidate(message: String)
    case failedToCreateExpense(title: String, transactions: [TransactionData], group: Group)
}

struct ExpenseService: ExpenseServiceType {

    func createExpense(title: String, amount: Double, lender: Person, createdAt: Date, transactions: [TransactionData], group: Group) -> Observable<Expense> {
        let result = PersistenceService.shared.withRealm("create expense") {
            (realm) -> Observable<Expense> in
            let expense = Expense.create(realm: realm,
                title: title, amount: amount, lender: lender,
                createdAt: createdAt, transactions: transactions)
            try realm.write {
                group.expenses.append(expense)
            }
            return .just(expense)
        }
        return result ?? .error(ExpenseServiceError.failedToCreateExpense(title: title, transactions: transactions, group: group))
    }
}
