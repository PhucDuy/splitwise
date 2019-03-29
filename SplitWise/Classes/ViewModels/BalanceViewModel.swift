//
//  BalanceViewModel.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/29/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
import NSObject_Rx


class BalanceViewModel: ViewModelType {
    let sceneCoordinator: SceneCoordinatorType
    let input: Input
    let output: Output
    let group: Group
    struct Input {
        
    }
    
    struct Output {
        let errorsObservable: Observable<Error>
    }
    
    private let errorsObservableSubject = PublishSubject<Error>()
    
    private let disposeBag = DisposeBag()
    
    init(coordinator: SceneCoordinatorType, group: Group) {
        self.group = group
        self.sceneCoordinator = coordinator
        self.input = Input()
        self.output = Output(errorsObservable: errorsObservableSubject.asObserver())
    }
    func balances() -> Observable<[TransactionData]> {
        return Observable.create({ (observer) -> Disposable in
            let splitEngine  = SplitEngine(expenses: self.group.expenses.toArray())
            observer.onNext(splitEngine.overallBalance())
            observer.onCompleted()
            return Disposables.create()
        })
    }
}
