//
//  ExpensesViewController.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/28/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import UIKit
import RxRealmDataSources
import RxSwift
import NSObject_Rx


class ExpensesViewController: UIViewController, BindableType {
    // MARK: - IBOutlet
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var viewModel: ExpensesViewModel!
    let cellIdentifier = "Cell"
    // MARK: - Properties
    lazy var dataSource: RxTableViewRealmDataSource<Expense> = {
        return RxTableViewRealmDataSource<Expense>(cellIdentifier: cellIdentifier) { (dataSource, tableView, indexPath, expense) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            let createdAt = dateFormatter.string(from: expense.createdDate)
             var content = "\(createdAt) - \(expense.title) - \(expense.amount) "
            if let lender = expense.lender {
                content += "- \(lender.name) paid"
            }
            cell.textLabel?.text = content
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
        setupBackNavigation()
    }
    
    func bindViewModel() {
        addButton.rx.tap.asObservable()
            .subscribe(viewModel.input.addExpenseButtonWasClicked)
            .disposed(by: self.rx.disposeBag)
        Observable.changeset(from: self.viewModel.expenses())
            .share().bind(to: tableView.rx.realmChanges(dataSource))
            .disposed(by: self.rx.disposeBag)
        tableView.rx.realmModelSelected(Expense.self)
            .subscribe(onNext: { [unowned self] (expense) in
                self.viewModel.input.expenseWasSelected.onNext(expense)
                if let selectedRowIndexPath = self.tableView.indexPathForSelectedRow {
                    self.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
                }
            }).disposed(by: self.rx.disposeBag)
    }


}
