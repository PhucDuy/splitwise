//
//  MembersViewController.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/26/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import UIKit
import RxRealmDataSources
import RxSwift
import NSObject_Rx

class MembersViewController: UIViewController, BindableType {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    var viewModel: MembersViewModel!
    var nameTextField: UITextField?
    let cellIdentifier = "Cell"
    lazy var dataSource: RxTableViewRealmDataSource<Person> = {
        return RxTableViewRealmDataSource<Person>(cellIdentifier: cellIdentifier) { (dataSource, tableView, indexPath, member) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
            cell.textLabel?.text = member.name
            return cell
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBackNavigation()
    }
    func bindViewModel() {
        addButton.rx.tap.asObservable()
            .subscribe(viewModel.input.addMemberButtonWasClicked)
            .disposed(by: self.rx.disposeBag)
        Observable.changeset(from: self.viewModel.group.members)
            .share().bind(to: tableView.rx.realmChanges(dataSource))
            .disposed(by: self.rx.disposeBag)
        viewModel.output.showCreateMemberPopUpObservable
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (event) in
                guard let strongSelf = self else { return }
                strongSelf.showCreateMemberPopUp()
            })
            .disposed(by: self.rx.disposeBag)
        tableView.rx.realmModelSelected(Person.self)
            .subscribe(onNext: { [unowned self] (person) in
                self.viewModel.input.memberWasSelected.onNext(person)
                if let selectedRowIndexPath = self.tableView.indexPathForSelectedRow {
                    self.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
                }
            }).disposed(by: self.rx.disposeBag)

    }
    func showCreateMemberPopUp() {
        let alert = UIAlertController(title: "Create Member", message: "Please fill member's name", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addTextField { (textField) in
            self.nameTextField = textField
        }
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: {
            action in
            if let name = self.nameTextField?.text, name.count > 0 {
                self.viewModel.input.createMember.onNext(name)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }


}
