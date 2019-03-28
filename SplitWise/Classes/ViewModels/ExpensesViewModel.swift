//
//  ExpensesViewModel.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/28/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
import NSObject_Rx


class ExpensesViewModel: ViewModelType {
    let service: ExpenseServiceType
    let sceneCoordinator: SceneCoordinatorType
    let input: Input
    let output: Output
    let group: Group
    struct Input {
        let addExpenseButtonWasClicked: AnyObserver<Void>
        let expenseWasSelected: AnyObserver<Expense>
        
    }
    
    struct Output {
        let errorsObservable: Observable<Error>
        let createExpenseObservable: Observable<Void>
    }
    
    private let addExpenseButtonWasClickedSubject = PublishSubject<Void>()
    private let createExpenseObservableSubject = PublishSubject<Void>()
    private let errorsObservableSubject = PublishSubject<Error>()
    private let expenseWasSelectedSubject = PublishSubject<Expense>()
    
    private let disposeBag = DisposeBag()
    
    
    
    init(service: ExpenseServiceType, coordinator: SceneCoordinatorType, group: Group) {
        self.service = service
        self.group = group
        self.sceneCoordinator = coordinator
        self.input = Input(addExpenseButtonWasClicked: self.addExpenseButtonWasClickedSubject.asObserver(),
                           expenseWasSelected: expenseWasSelectedSubject.asObserver())
        self.output = Output(errorsObservable: errorsObservableSubject.asObserver(),
                             createExpenseObservable: self.createExpenseObservableSubject.asObservable())
        
        self.addExpenseButtonWasClickedSubject.subscribe(onNext: {
            [weak self] event in
            guard let strongSelf = self else { return }
            let editViewModel = EditExpenseViewModel(service: strongSelf.service,
                                                     coordinator: strongSelf.sceneCoordinator,
                                                     group: strongSelf.group)
            strongSelf.sceneCoordinator.transition(to: .editExpenses(editViewModel), type: .modal)
        }).disposed(by: self.disposeBag)
        self.expenseWasSelectedSubject.subscribe(onNext: { [weak self] (group) in
            guard let strongSelf = self else { return }
//            let viewModel = GroupViewModel(group: group,
//                                           coordinator: strongSelf.sceneCoordinator)
//            strongSelf.sceneCoordinator.transition(to: .group(viewModel), type: .push)
        }).disposed(by: self.disposeBag)
    }
    func expenses() -> List<Expense> {
        return self.group.expenses
    }
    
}
