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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }


    // MARK: - BindableType
    func bindViewModel() {
        addButton.rx.tap.asObservable()
            .subscribe(viewModel.input.addGroupButtonWasClicked)
            .disposed(by: self.rx.disposeBag)
        viewModel.groups.take(1).subscribe(onNext: { [unowned self] (groups) in
            Observable.changeset(from: groups).share().bind(to: self.tableView.rx.realmChanges(self.dataSource)).disposed(by: self.rx.disposeBag)
        }).disposed(by: self.rx.disposeBag)
        
        tableView.rx.realmModelSelected(Group.self)
            .subscribe(onNext: { [unowned self] (group) in
                self.viewModel.input.groupWasSelected.onNext(group)
                if let selectedRowIndexPath = self.tableView.indexPathForSelectedRow {
                    self.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
                }
            }).disposed(by: self.rx.disposeBag)
    }
}

