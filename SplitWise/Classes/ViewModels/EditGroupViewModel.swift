//
//  EditGroupViewModel.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/25/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import Foundation
import RxSwift
import NSObject_Rx

class EditGroupViewModel: ViewModelType {
    struct Input {
        let name: AnyObserver<String>
        let info: AnyObserver<String?>
        let saveButtonWasClicked: AnyObserver<Void>
        let cancelButtonWasClicked: AnyObserver<Void>
    }
    struct Output {
        let errorObservable: Observable<Error>
    }
    // MARK: - Public properties
    let input: Input
    let output: Output

    struct GroupData {
        var name: String
        var info: String?
    }

    // MARK: - Private properties
    private let nameSubject = BehaviorSubject<String>(value: "")
    private let infoSubject = BehaviorSubject<String?>(value: "")
    private let saveButtonWasClickedSubject = PublishSubject<Void>()
    private var cancelButtonWasClickedSubject = PublishSubject<Void>()
    private let saveResultSubject = PublishSubject<Group>()
    private let errorsSubject = PublishSubject<Error>()
    private var group: Group?
    private let disposeBag = DisposeBag()
    private let groupService: GroupServiceType
    private let sceneCoordinator: SceneCoordinatorType
    private var nameValid: Observable<Bool> {
        return nameSubject.asObservable().map { $0.count > 0 }
    }

    private var GroupDataObservable: Observable<GroupData> {
        return Observable.combineLatest(nameSubject.asObservable(), infoSubject.asObservable()) {
            name, info in
            return GroupData(name: name, info: info)
        }
    }

    func validateData(data: GroupData) -> Observable<GroupData> {
        return Observable<GroupData>.create({ (observer) -> Disposable in
            if data.name.isEmpty {
                observer.onError(GroupServiceError
                        .failedToCreateGroup(name: data.name, description: data.info))
            } else {
                observer.onNext(data)
            }
            observer.onCompleted()
            return Disposables.create()
        })
    }

    init(groupService: GroupServiceType, coordinator: SceneCoordinatorType, group: Group? = nil) {
        if let group = group {
            self.group = group
        }
        self.sceneCoordinator = coordinator
        self.groupService = groupService
        input = Input(name: nameSubject.asObserver(),
            info: infoSubject.asObserver(),
            saveButtonWasClicked: saveButtonWasClickedSubject.asObserver(),
            cancelButtonWasClicked: cancelButtonWasClickedSubject.asObserver())

        output = Output(errorObservable: errorsSubject.asObservable())
        self.cancelButtonWasClickedSubject
            .subscribe(onNext: { [unowned self] (event) in
                self.sceneCoordinator.pop()
            }).disposed(by: disposeBag)

        self.saveButtonWasClickedSubject
            .withLatestFrom(GroupDataObservable)
            .subscribe(onNext: { [weak self] (data) in
                self?.createGroup(data: data)
            }).disposed(by: self.disposeBag)
    }
    func createGroup(data: GroupData) {
        self.validateData(data: data)
            .flatMap { [unowned self] data in
                return self.groupService.createGroup(name: data.name, description: data.info).single()
            }.subscribe(onNext: { [unowned self] (currGroup) in
                self.sceneCoordinator.pop()
            }, onError: { [unowned self](error) in
                    self.errorsSubject.onNext(error)
                })
            .disposed(by: self.disposeBag)
    }

}
