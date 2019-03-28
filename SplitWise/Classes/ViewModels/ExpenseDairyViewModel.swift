//
//  ExpenseDairyViewModel.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/28/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
import NSObject_Rx


class ExpenseDairyViewModel: ViewModelType {
    let sceneCoordinator: SceneCoordinatorType
    let input: Input
    let output: Output
    let group: Group
    let person: Person
    struct Input {

    }

    struct Output {
        let errorsObservable: Observable<Error>
    }

    private let errorsObservableSubject = PublishSubject<Error>()

    private let disposeBag = DisposeBag()



    init(coordinator: SceneCoordinatorType, group: Group, person: Person) {
        self.group = group
        self.person = person
        self.sceneCoordinator = coordinator
        self.input = Input()
        self.output = Output(errorsObservable: errorsObservableSubject.asObserver())
    }
    func expenses() -> Observable<[Expense]> {
        return Observable<[Expense]>.create({ (observer) -> Disposable in
            let expenses = self.group.expenses.toArray().filter { (expense) -> Bool in
                if let uid = expense.lender?.uid {
                    return uid == self.person.uid
                }
                return false
            }
            observer.onNext(expenses)
            observer.onCompleted()
            return Disposables.create()

        })
    }

}
