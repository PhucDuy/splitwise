//
//  GroupViewModel.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/26/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import Foundation
import RxSwift


class GroupViewModel: ViewModelType {
    let group: Group
    let sceneCoordinator: SceneCoordinatorType
    struct Input {
        let membersButtonWasClicked: AnyObserver<Void>
        let balanceButtonWasClicked: AnyObserver<Void>
        let expensesButtonWasClicked: AnyObserver<Void>
    }

    struct Output {
    }
    let input: Input
    let output: Output
    private let membersButtonWasClickedSubject = PublishSubject<Void>()
    private let balanceButtonWasClickedSubject = PublishSubject<Void>()
    private let expensesButtonWasClickedSubject = PublishSubject<Void>()

    private let disposeBag = DisposeBag()
    init(group: Group, coordinator: SceneCoordinatorType) {
        self.group = group
        self.sceneCoordinator = coordinator
        self.input = Input(membersButtonWasClicked: self.membersButtonWasClickedSubject.asObserver()
            , balanceButtonWasClicked: self.balanceButtonWasClickedSubject.asObserver()
            , expensesButtonWasClicked: self.expensesButtonWasClickedSubject.asObserver())
        self.output = Output()

        membersButtonWasClickedSubject
            .subscribe(onNext: { [weak self](observer) in
                guard let strongSelf = self else { return }
                let viewModel = MembersViewModel(service: MemberService(), coordinator: strongSelf.sceneCoordinator, group: strongSelf.group)
                strongSelf.sceneCoordinator.transition(to: .members(viewModel), type: .push)
            }).disposed(by: disposeBag)
        balanceButtonWasClickedSubject
            .subscribe(onNext: { [weak self](observer) in


            }).disposed(by: disposeBag)
        expensesButtonWasClickedSubject
            .subscribe(onNext: { [weak self](observer) in


            }).disposed(by: disposeBag)
    }

}
