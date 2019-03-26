//
//  EditGroupViewController.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/25/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Action
import NSObject_Rx
import Eureka

class EditGroupViewController: FormViewController , BindableType {
    // MARK: - IBOutlet
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var viewModel: EditGroupViewModel!
    
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
    }
    func presentError(_ error: Error) {
        print("Error: \(error.localizedDescription)")
//        alert("Error", description: "Name value is required. Please fill name value and try again.")
//            .subscribeOn(MainScheduler.instance)
//            .subscribe().disposed(by: self.rx.disposeBag)
    }
    

    
}


