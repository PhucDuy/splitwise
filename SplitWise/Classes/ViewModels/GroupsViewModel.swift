//
//  GroupViewModel.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/25/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import NSObject_Rx


class GroupsViewModel: ViewModelType {
    let groupService: GroupServiceType
    let sceneCoordinator: SceneCoordinatorType
    let input: Input
    let output: Output

    struct Input {
        let addGroupButtonWasClicked: AnyObserver<Void>
    }

    struct Output {
        let errorsObservable: Observable<Error>
        let createGroupObservable: Observable<Void>
    }

    private let addGroupButtonWasClickedSubject = PublishSubject<Void>()
    private let createGroupObservableSubject = PublishSubject<Void>()
    private let errorsObservableSubject = PublishSubject<Error>()
    private let disposeBag = DisposeBag()
    

    init(groupService: GroupServiceType, coordinator: SceneCoordinatorType) {
        self.groupService = groupService
        self.sceneCoordinator = coordinator
        self.input = Input(addGroupButtonWasClicked: addGroupButtonWasClickedSubject.asObserver())
        self.output = Output(errorsObservable: errorsObservableSubject.asObservable()
            , createGroupObservable: createGroupObservableSubject.asObservable())
        
        self.addGroupButtonWasClickedSubject.subscribe(onNext: {
            [unowned self] event in
            let editViewModel = EditGroupViewModel(groupService: self.groupService
                , coordinator: self.sceneCoordinator)
            self.sceneCoordinator.transition(to: Scene.editGroup(editViewModel)
                , type: .modal)
        }).disposed(by: self.disposeBag)
    }
    var sectionsedItems: Observable<[GroupSection]> {
        return self.groupService.groups().map({ (results) in
            let groups = results.toArray()
            return [GroupSection(model: "Group", items: groups)]
        })
    }
}
