//
//  BalanceViewController.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/29/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import NSObject_Rx

class BalanceViewController: UIViewController, BindableType {
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    var viewModel: BalanceViewModel!
    let cellIdentifier = "Cell"
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBackNavigation()
    }

    // MARK: - BindableType
    func bindViewModel() {
        viewModel.balances().bind(to: tableView.rx.items(cellIdentifier: cellIdentifier)) {
            index, balance, cell in
            if let lender = balance.lender, let lendee = balance.lendee {
                let amountStr = String(format: "%.2f", balance.amount)
                let content = "\(lendee.name) owes \(lender.name) $\(amountStr)"
                cell.textLabel?.text = content
            }
            
            }.disposed(by: self.rx.disposeBag)
        tableView.rx.modelSelected(TransactionData.self).subscribe(onNext: { [unowned self] (balance) in
            if let selectedRowIndexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
            }
            
        }).disposed(by: self.rx.disposeBag)

    }
}
