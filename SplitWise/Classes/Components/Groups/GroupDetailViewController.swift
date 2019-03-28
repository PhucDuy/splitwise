//
//  GroupDetailViewController.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/26/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import UIKit
import RxSwift
import RxRealmDataSources
import NSObject_Rx

class GroupDetailViewController: UIViewController, BindableType {
    @IBOutlet weak var membersButton: UIButton!
    @IBOutlet weak var expensesButton: UIButton!
    @IBOutlet weak var balanceButton: UIButton!
    var viewModel: GroupViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.viewModel.group.name
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBackNavigation()
    }
    
    func bindViewModel() {
        membersButton.rx.tap.asObservable()
            .subscribe(viewModel.input.membersButtonWasClicked)
            .disposed(by: self.rx.disposeBag)
        expensesButton.rx.tap.asObservable()
            .subscribe(viewModel.input.expensesButtonWasClicked)
            .disposed(by: self.rx.disposeBag)
        balanceButton.rx.tap.asObservable()
            .subscribe(viewModel.input.balanceButtonWasClicked)
            .disposed(by: self.rx.disposeBag)
        Observable.collection(from: viewModel.group.members).subscribe(onNext: { (values) in
            self.expensesButton.isEnabled = values.count > 0
            self.expensesButton.isHidden = !(values.count > 0)
        }).disposed(by: self.rx.disposeBag)
        Observable.collection(from: viewModel.group.expenses).subscribe(onNext: { (values) in
            self.balanceButton.isEnabled = values.count > 0
            self.balanceButton.isHidden = !(values.count > 0)
        }).disposed(by: self.rx.disposeBag)
    }
}
