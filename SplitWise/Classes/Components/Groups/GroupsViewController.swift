//
//  GroupsViewController.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/25/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import Action
import NSObject_Rx

class GroupsViewController: UIViewController, BindableType {
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    // MARK: - Properties
    var viewModel: GroupsViewModel!

    let groupCellIdentifier = "Cell"
    let addGroupSegue = "AddGroupSegue"
    lazy var dataSource: RxTableViewSectionedReloadDataSource<GroupSection> = {
        return RxTableViewSectionedReloadDataSource<GroupSection>(configureCell: {
            [unowned self] dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: self.groupCellIdentifier, for: indexPath)
            cell.textLabel?.text = item.name
            return cell
        })
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
        
        viewModel.sectionsedItems
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.rx.disposeBag)
    }
    // MARK: - Navigation
}

