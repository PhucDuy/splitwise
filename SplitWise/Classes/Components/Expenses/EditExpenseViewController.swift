//
//  EditExpenseViewController.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/28/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Eureka


class EditExpenseViewController: FormViewController, BindableType {
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    var viewModel: EditExpenseViewModel!

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.createForm()
        self.form = viewModel.form
        self.tableView.tableFooterView = UIView()
    }
    func bindViewModel() {
        cancelButton.rx.tap.asObservable()
            .subscribe(viewModel.input.cancelButtonWasClicked)
            .disposed(by: self.rx.disposeBag)
        saveButton.rx.tap.asObservable()
            .subscribe(viewModel.input.saveButtonWasClicked)
            .disposed(by: self.rx.disposeBag)

        viewModel.output.errorObservable
            .subscribe(onNext: { [unowned self] (error) in
                self.presentError(error)
            })
            .disposed(by: self.rx.disposeBag)
        viewModel.output.reloadFormObservable
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in
                self.tableView.reloadData()
            }).disposed(by: self.rx.disposeBag)
    }
    func presentError(_ error: Error) {
        print("Error: \(error.localizedDescription)")
        if let error = error as? ExpenseServiceError {
            switch error {
            case .failedToValidate(message: let message):
                alert(message).subscribeOn(MainScheduler.instance)
                    .delay(0.5, scheduler: MainScheduler.init()).subscribe()
                    .disposed(by: self.rx.disposeBag)
            default:
                break
            }
        }
        //        alert("Error", description: "Name value is required. Please fill name value and try again.")
        //            .subscribeOn(MainScheduler.instance)
        //            .subscribe().disposed(by: self.rx.disposeBag)
    }



}
