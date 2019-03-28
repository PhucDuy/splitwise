//
//  MembersViewModel.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/26/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import Foundation
import RxSwift
import RxRealm
import NSObject_Rx
import RealmSwift
import RxRealmDataSources


class MembersViewModel: ViewModelType {
    let service: MemberService
    let sceneCoordinator: SceneCoordinatorType
    let input: Input
    let output: Output
    let group: Group
    struct Input {
        let addMemberButtonWasClicked: AnyObserver<Void>
        let createMember: AnyObserver<String>
        let memberWasSelected: AnyObserver<Person>
    }

    struct Output {
        let errorsObservable: Observable<Error>
        let showCreateMemberPopUpObservable: Observable<Void>
    }

    private let addMemberButtonWasClickedObserver = PublishSubject<Void>()
    private let showCreateMemberPopUpObservable = PublishSubject<Void>()
    private let createMemberObserver = PublishSubject<String>()
    private let memberWasSelectedObserver = PublishSubject<Person>()
    private let errorsObservable = PublishSubject<Error>()
    private let disposeBag = DisposeBag()


    init(service: MemberService, coordinator: SceneCoordinatorType, group: Group) {
        self.service = service
        self.sceneCoordinator = coordinator
        self.group = group
        self.input = Input(addMemberButtonWasClicked: self.addMemberButtonWasClickedObserver.asObserver(),
            createMember: self.createMemberObserver.asObserver(),
            memberWasSelected: memberWasSelectedObserver.asObserver())
        self.output = Output(errorsObservable: self.errorsObservable.asObservable(),
            showCreateMemberPopUpObservable: self.showCreateMemberPopUpObservable.asObservable())
        self.addMemberButtonWasClickedObserver.subscribe({
            [weak self] event in
            guard let strongSelf = self else { return }
            strongSelf.showCreateMemberPopUpObservable.onNext(())
        }).disposed(by: self.disposeBag)
        self.createMemberObserver.subscribe(onNext: { [weak self] (name) in
            guard let strongSelf = self else { return }
            strongSelf.createMember(name: name, group: strongSelf.group)

        }).disposed(by: self.disposeBag)
        self.memberWasSelectedObserver.subscribe(onNext: { [weak self] (person) in
            guard let strongSelf = self else { return }
            let viewModel = ExpenseDairyViewModel(coordinator: strongSelf.sceneCoordinator
                , group: strongSelf.group, person: person)
            strongSelf.sceneCoordinator.transition(to: .expenseDairy(viewModel), type: .push)
        }).disposed(by: self.disposeBag)
    }
    func members() -> List<Person> {
        return self.group.members
    }
    func createMember(name: String, group: Group) {
        self.service.createPerson(name: name, group: group).subscribe().disposed(by: disposeBag)
    }
}
