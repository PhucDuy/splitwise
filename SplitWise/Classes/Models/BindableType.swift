//
//  BindableType.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/25/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import Foundation
import RxSwift
import Action

protocol BindableType: class {
    associatedtype T: ViewModelType
    var viewModel: T! { get set }
    func bindViewModel()
}
extension BindableType where Self: UIViewController {
    func bindViewModel(to model: Self.T) {
        viewModel = model
        loadViewIfNeeded()
        bindViewModel()
    }
}

protocol ViewModelType: class {
    var sceneCoordinator: SceneCoordinatorType { get }
    associatedtype Input
    associatedtype Output
}

extension ViewModelType {
    func backAction() -> CocoaAction {
        return CocoaAction {
            self.sceneCoordinator.pop()
            return Observable.empty()
        }
    }
}

extension BindableType where Self: UIViewController {
    fileprivate func shouldSetupBackNavigation() -> Bool {
        guard let navigation = self.navigationController else {
            return false
        }

        guard let selfIndex = navigation.viewControllers.index(of: self) else {
            return false
        }

        let stackCount = navigation.viewControllers.count
        return selfIndex == (stackCount - 1)
    }

    func setupBackNavigation() {
        guard shouldSetupBackNavigation() else {
            return
        }

        self.navigationItem.hidesBackButton = true
        
        var backButton = UIBarButtonItem.backButton()
        self.navigationItem.leftBarButtonItem = backButton
        backButton.rx.action = viewModel.backAction()
    }
}
