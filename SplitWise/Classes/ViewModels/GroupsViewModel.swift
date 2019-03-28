//
//  GroupViewModel.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/25/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift
import NSObject_Rx


class GroupsViewModel: ViewModelType {
    let groupService: GroupServiceType
    let sceneCoordinator: SceneCoordinatorType
    let input: Input
    let output: Output

    struct Input {
        let addGroupButtonWasClicked: AnyObserver<Void>
        let groupWasSelected: AnyObserver<Group>

    }

    struct Output {
        let errorsObservable: Observable<Error>
        let createGroupObservable: Observable<Void>
    }
    
    private let addGroupButtonWasClickedSubject = PublishSubject<Void>()
    private let createGroupObservableSubject = PublishSubject<Void>()
    private let errorsObservableSubject = PublishSubject<Error>()
    private let groupWasSelectedSubject = PublishSubject<Group>()

    private let disposeBag = DisposeBag()
    
    

    init(groupService: GroupServiceType, coordinator: SceneCoordinatorType) {
        self.groupService = groupService
        self.sceneCoordinator = coordinator
        self.input = Input(addGroupButtonWasClicked: addGroupButtonWasClickedSubject.asObserver()
            , groupWasSelected: self.groupWasSelectedSubject.asObserver())
        self.output = Output(errorsObservable: errorsObservableSubject.asObservable()
            , createGroupObservable: createGroupObservableSubject.asObservable())

        self.addGroupButtonWasClickedSubject.subscribe(onNext: {
            [weak self] event in
            guard let strongSelf = self else { return }
            let editViewModel = EditGroupViewModel(groupService: strongSelf.groupService
                , coordinator: strongSelf.sceneCoordinator)
            strongSelf.sceneCoordinator.transition(to: Scene.editGroup(editViewModel)
                , type: .modal)
        }).disposed(by: self.disposeBag)
        self.groupWasSelectedSubject.subscribe(onNext: { [weak self] (group) in
            guard let strongSelf = self else { return }
            let viewModel = GroupViewModel(group: group,
                                           coordinator: strongSelf.sceneCoordinator)
            strongSelf.sceneCoordinator.transition(to: .group(viewModel), type: .push)
        }).disposed(by: self.disposeBag)
    }
    var groups: Observable<Results<Group>>{
        return self.groupService.groups()
    }    
}
