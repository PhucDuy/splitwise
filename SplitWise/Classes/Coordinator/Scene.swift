//
//  Scene.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/25/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import Foundation
enum Scene {
    case groups(GroupsViewModel)
    case editGroup(EditGroupViewModel)
    case members(MembersViewModel)
    case group(GroupViewModel)
    case expenses(ExpensesViewModel)
    case editExpenses(EditExpenseViewModel)
    case expenseDairy(ExpenseDairyViewModel)
}

