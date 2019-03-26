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

class EditGroupViewController: UIViewController, BindableType {
    // MARK: - IBOutlet
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var viewModel: EditGroupViewModel!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    func bindViewModel() {
        nameTextField.rx.text.orEmpty.asObservable()
            .subscribe(viewModel.input.name)
            .disposed(by: self.rx.disposeBag)
        descriptionTextView.rx.text.asObservable()
            .subscribe(viewModel.input.info)
            .disposed(by: self.rx.disposeBag)
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
        let alert = UIAlertController(title: "Error",
                                      message: "Name value is required. Please fill name value and try again.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    

    
}


