//
//  ExpenseDiaryViewController.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/28/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import NSObject_Rx


class ExpenseDiaryViewController: UIViewController, BindableType {
    @IBOutlet weak var tableView: UITableView!
    var viewModel: ExpenseDairyViewModel!
    let cellIdentifier = "Cell"
    // MARK: - Properties
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.navigationItem.title = self.viewModel.person.name
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBackNavigation()
    }

    func bindViewModel() {
        viewModel.expenses().bind(to: tableView.rx.items(cellIdentifier: cellIdentifier)) {
            index, expense, cell in
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            let createdAt = dateFormatter.string(from: expense.createdDate)
            let content = "\(createdAt) - \(expense.title) - \(expense.amount) "
            cell.textLabel?.text = content
        }.disposed(by: self.rx.disposeBag)
        tableView.rx.modelSelected(Expense.self).subscribe(onNext: { [unowned self] (expense) in
            if let selectedRowIndexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
            }

        }).disposed(by: self.rx.disposeBag)
    }

}
