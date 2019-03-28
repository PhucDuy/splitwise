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
import Eureka


class EditGroupViewModel: ViewModelType {
    struct Input {
        let name: AnyObserver<String?>
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
    let form: Form

    // MARK: - Private properties
    private let nameSubject = BehaviorSubject<String?>(value: "")
    private let infoSubject = BehaviorSubject<String?>(value: "")
    private let saveButtonWasClickedSubject = PublishSubject<Void>()
    private var cancelButtonWasClickedSubject = PublishSubject<Void>()
    private let errorsSubject = PublishSubject<Error>()
    private var group: Group?
    private let disposeBag = DisposeBag()
    private let groupService: GroupServiceType
    internal let sceneCoordinator: SceneCoordinatorType

    private var groupDataObservable: Observable<GroupData> {
        return Observable.combineLatest(nameSubject.asObservable(), infoSubject.asObservable()) {
            name, info in
            
            return GroupData(name: name ?? "", info: info)
        }
    }

    func validateData(data: GroupData) -> Observable<GroupData> {
        return Observable<GroupData>.create({ (observer) -> Disposable in
            if self.form.validate().count == 0 {
                observer.onNext(data)
            } else {
                observer.onError(GroupServiceError
                        .failedToCreateGroup(name: data.name, description: data.info))
            }
            observer.onCompleted()
            return Disposables.create()
        })
    }

    init(groupService: GroupServiceType, coordinator: SceneCoordinatorType, group: Group? = nil) {
        if let group = group {
            self.group = group
        }
        self.form = Form()
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
            .withLatestFrom(self.groupDataObservable)
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
    func createForm() {
        form +++ Section()
        <<< TextRow() { row in
            row.title = "Name"
            row.add(rule: RuleRequired())
            row.placeholder = "Enter name here."
            row.validationOptions = .validatesOnChange
            row.rx.value.bind(to: self.input.name).disposed(by: self.disposeBag)
        }.cellUpdate { cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .red
            }
        }
        <<< TextAreaRow { row in
            row.title = "Description"
            row.placeholder = "Enter group's description here."
            row.rx.value.bind(to: self.infoSubject).disposed(by: self.disposeBag)
        }.onChange({ (textRow) in
            if let value = textRow.value {
                self.infoSubject.onNext(value)
            }
        })

    }
}
