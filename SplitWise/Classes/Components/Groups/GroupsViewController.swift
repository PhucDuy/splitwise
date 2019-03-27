//
//  GroupsViewController.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/25/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import UIKit
import RxSwift
import RxRealmDataSources
import RxRealm
import Action
import NSObject_Rx

class GroupsViewController: UIViewController, BindableType {
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    // MARK: - Properties
    var viewModel: GroupsViewModel!

    let cellIdentifier = "Cell"
    let addGroupSegue = "AddGroupSegue"
    lazy var dataSource: RxTableViewRealmDataSource<Group> = {
        return RxTableViewRealmDataSource<Group>(cellIdentifier: cellIdentifier) { (dataSource, tableView, indexPath, group) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
            cell.textLabel?.text = group.name
            cell.detailTextLabel?.text = group.info
            return cell
        }
    }()


    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }

    // MARK: - Action

    // MARK: - BindableType
    func bindViewModel() {
        addButton.rx.tap.asObservable()
            .subscribe(viewModel.input.addGroupButtonWasClicked)
            .disposed(by: self.rx.disposeBag)
        viewModel.groups.subscribe(onNext: { [unowned self] (groups) in
            Observable.changeset(from: groups).share().bind(to: self.tableView.rx.realmChanges(self.dataSource)).disposed(by: self.rx.disposeBag)
        }).disposed(by: self.rx.disposeBag)
        tableView.rx.realmModelSelected(Group.self)
            .subscribe(viewModel.input.groupWasSelected).disposed(by: self.rx.disposeBag)
    }
}

