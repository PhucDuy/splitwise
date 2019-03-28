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
    func createExpense(title: String, amount: Double,
        lender: Person,
        createdAt: Date,
        transactions: [TransactionData],
        group: Group) -> Observable<Expense>
    func updateExpense(expense: Expense,
        title: String, amount: Double,
        lender: Person,
        createdAt: Date,
        transactions: [TransactionData],
        group: Group) -> Observable<Expense>
    func deleteExpense(expense: Expense) -> Observable<Expense>


}
enum ExpenseServiceError: Error {
    case failedToValidate(message: String)
    case failedToDelete(message: String)
    case failedToUpdate(message: String)
    case failedToCreateExpense(title: String, transactions: [TransactionData], group: Group)
}

struct ExpenseService: ExpenseServiceType {
    func updateExpense(expense: Expense, title: String, amount: Double, lender: Person, createdAt: Date, transactions: [TransactionData], group: Group) -> Observable<Expense> {
        let result = PersistenceService.shared.withRealm("Update expense") { (realm) -> Observable<Expense> in
            try realm.write {
                expense.title = title
                expense.amount = amount
                expense.lender = lender
                expense.createdDate = createdAt
                expense.transactions.removeAll()
                transactions.forEach({ (data) in
                    expense.transactions.append(Transaction.create(realm: realm, data: data, lender: lender))
                })
            }
            return .just(expense)
        }
        return result ?? .error(ExpenseServiceError.failedToUpdate(message: "Failed to update expense"))
    }
    func deleteExpense(expense: Expense) -> Observable<Expense> {
        return PersistenceService.shared.delete(object: expense)
    }
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
