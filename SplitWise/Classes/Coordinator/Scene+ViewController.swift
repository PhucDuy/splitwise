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
            var vc = nav.viewControllers.first as! GroupsViewController
            vc.bindViewModel(to: viewModel)
            return nav
        case .editGroup(let viewModel):
            let nav = storyboard.instantiateViewController(withIdentifier: "EditGroup") as! UINavigationController
            var vc = nav.viewControllers.first as! EditGroupViewController
            vc.bindViewModel(to: viewModel)
            return nav
        }
    }
}
