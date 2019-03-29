//
//  SplitEngine.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/29/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import Foundation

class SplitEngine: NSObject {
    let expenses: [Expense]
    init(expenses: [Expense]) {
        self.expenses = expenses
    }
    func overallBalance() -> [TransactionData] {


        let transactions = self.expenses.map { (expense) -> [TransactionData] in
            return expense.transactionArray()
        }.flatMap { (elements) -> [TransactionData] in
            return elements
        }
        var memberNetAmounts = findNetAmountOfEachPerson(from: transactions)
        print(memberNetAmounts)
        var results = [TransactionData]()
        // settling
        while memberNetAmounts.count > 1 {
            if let minObj = memberNetAmounts.max(by: { (obj1, obj2) -> Bool in
                return obj1.value > obj2.value
            }), let maxObj = memberNetAmounts.max(by: { (obj1, obj2) -> Bool in
                    return obj1.value < obj2.value
                }) {
                let payback = min(-minObj.value, maxObj.value)
                let newMaxValue = maxObj.value - payback
                if newMaxValue == 0 {
                    memberNetAmounts.removeValue(forKey: maxObj.key)
                } else {
                    memberNetAmounts[maxObj.key] = newMaxValue
                }
                let newMinValue = minObj.value + payback
                if newMinValue == 0 {
                    memberNetAmounts.removeValue(forKey: minObj.key)
                } else {
                    memberNetAmounts[minObj.key] = newMinValue
                }
                results.append(TransactionData(lender: maxObj.key, lendee: minObj.key, amount: payback))
            } else {
                memberNetAmounts.removeAll()
            }
        }


        return results
    }

    func findNetAmountOfEachPerson(from transactions: [TransactionData]) -> [Person: Double] {
        var memberValues = [Person: Double]()
        print(transactions)
        for transaction in transactions {
            if let lender = transaction.lender,
                let lendee = transaction.lendee {
                if lender.uid != lendee.uid {
                    if let value = memberValues[lender] {
                        memberValues[lender] = value + transaction.amount
                    } else {
                        memberValues[lender] = transaction.amount
                    }
                    if let value = memberValues[lendee] {
                        memberValues[lendee] = value - transaction.amount
                    } else {
                        memberValues[lendee] = -transaction.amount
                    }
                }
            }
        }
        return memberValues
    }
}
