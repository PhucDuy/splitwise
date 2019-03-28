//
//  Scene+ViewController.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/25/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import Foundation
import UIKit

extension Scene {
    func viewController(storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)) -> UIViewController? {
        switch self {
        case .groups(let viewModel):
            let nav = storyboard.instantiateViewController(withIdentifier: "Groups") as! UINavigationController
            let vc = nav.viewControllers.first as! GroupsViewController
            vc.bindViewModel(to: viewModel)
            return nav
        case .editGroup(let viewModel):
            let nav = storyboard.instantiateViewController(withIdentifier: "EditGroup") as! UINavigationController
            let vc = nav.children.first as! EditGroupViewController
            vc.bindViewModel(to: viewModel)
            return nav
        case .members(let viewModel):
            let vc = storyboard.instantiateViewController(withIdentifier: "MembersViewController") as! MembersViewController
            vc.bindViewModel(to: viewModel)
            return vc
        case .group(let viewModel):
            let vc = storyboard.instantiateViewController(withIdentifier: "GroupDetailViewController") as! GroupDetailViewController
            vc.bindViewModel(to: viewModel)
            return vc
        case .expenses(let viewModel):
            let vc = storyboard.instantiateViewController(withIdentifier: "ExpensesViewController") as! ExpensesViewController
            vc.bindViewModel(to: viewModel)
            return vc
        case .editExpenses(let viewModel):
            let nav = storyboard.instantiateViewController(withIdentifier: "EditExpense") as! UINavigationController
            let vc = nav.children.first as! EditExpenseViewController
            vc.bindViewModel(to: viewModel)
            return nav

        }
    }
}
