//
//  EditExpenseViewModel.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/28/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import NSObject_Rx
import Eureka

class EditExpenseViewModel: ViewModelType {
    struct Input {
        let saveButtonWasClicked: AnyObserver<Void>
        let cancelButtonWasClicked: AnyObserver<Void>
    }
    struct Output {
        let errorObservable: Observable<Error>
        let reloadFormObservable: Observable<Void>
    }

    struct ExpenseData {
        var title: String
        var createdDate: Date
        var amount: Double
        var payPerson: Person
    }
    // MARK: - Public properties
    let input: Input
    let output: Output
    let form: Form
    let group: Group
    let expense: Expense?

    internal let sceneCoordinator: SceneCoordinatorType
    let service: ExpenseServiceType
    // MARK: - Private
    private let saveButtonWasClickedSubject = PublishSubject<Void>()
    private var cancelButtonWasClickedSubject = PublishSubject<Void>()
    private let saveResultSubject = PublishSubject<Expense>()
    private let errorsSubject = PublishSubject<Error>()
    private let disposeBag = DisposeBag()
    private let whoPayChangedObserver = PublishSubject<Person>()
    private var reloadFormObservable = PublishSubject<Void>()
    private var transactionRows = [DecimalRow]()
    private var transactions = [TransactionData]()
    private let titleVariable = BehaviorRelay<String?>(value: "")
    private let amountVariable = BehaviorRelay<Double?>(value: 0)
    private var createdAtVariable = BehaviorRelay<Date?>(value: Date())
    private var expenseDataObservable: Observable<ExpenseData?> {
        return Observable.combineLatest(whoPayChangedObserver.asObservable()
            , titleVariable.asObservable()
            , amountVariable.asObservable(),
            createdAtVariable.asObservable()) {
            payPerson, title, amount, createdAt in
            if let title = title,
                let amount = amount,
                let createdAt = createdAt {
                return ExpenseData(title: title, createdDate: createdAt, amount: amount, payPerson: payPerson)
            } else {
                return nil
            }

        }
    }

    init(service: ExpenseServiceType, coordinator: SceneCoordinatorType, group: Group, expense: Expense? = nil) {
        self.expense = expense
        self.form = Form()
        self.group = group
        self.sceneCoordinator = coordinator
        self.service = service
        self.input = Input(saveButtonWasClicked: saveButtonWasClickedSubject.asObserver(),
            cancelButtonWasClicked: cancelButtonWasClickedSubject.asObserver())
        output = Output(errorObservable: errorsSubject.asObservable(),
            reloadFormObservable: reloadFormObservable)
        self.cancelButtonWasClickedSubject
            .subscribe(onNext: { [weak self] (event) in
                guard let strongSelf = self else { return }
                strongSelf.sceneCoordinator.pop()
            }).disposed(by: disposeBag)

        self.saveButtonWasClickedSubject
            .withLatestFrom(self.expenseDataObservable)
            .subscribe(onNext: { (data) in
                if let data = data {
                    self.createExpense(data: data)
                }
            }).disposed(by: self.disposeBag)

        amountVariable.asDriver().debounce(0.5).drive(onNext: { (value) in
            if let value = value {
                let split = value / Double(self.transactions.count)
                self.transactionRows.forEach({ (row) in
                    row.value = split
                    row.updateCell()
                })
            }
        }).disposed(by: self.disposeBag)
        makeDefaultData()
    }

    private func makeDefaultData() {
        self.transactions.removeAll()
        if let expense = self.expense {
            self.amountVariable.accept(expense.amount)
            self.titleVariable.accept(expense.title)
            self.createdAtVariable.accept(expense.createdDate)
            if let lender = expense.lender {
                self.whoPayChangedObserver.onNext(lender)
            }
            self.transactions = expense.transactions.map { (transation) -> TransactionData in
                return transation.toData()
            }
        } else {
            self.transactions = self.group.members.map { (person) -> TransactionData in
                return TransactionData(lendee: person, amount: 0)
            }
        }
    }
    // MARK: - Validation
    func validate(data: ExpenseData) -> Observable<ExpenseData> {
        return Observable<ExpenseData>.create({ (observer) -> Disposable in
            if self.form.validate().count == 0 {
                observer.onNext(data)
            } else {
                observer.onError(ExpenseServiceError.failedToValidate(message: "Please fill all information before save."))
            }

            observer.onCompleted()
            return Disposables.create()
        })
    }

    func validate(transactions: [TransactionData]) -> Observable<[TransactionData]> {
        return Observable<[TransactionData]>.create({ [weak self] (observer) -> Disposable in
            if let strongSelf = self {
                if let amount = strongSelf.amountVariable.value {
                    let totalTransactionAmount = transactions.reduce(0.0, { (result, transaction) -> Double in
                        result + transaction.amount
                    })
                    if amount == totalTransactionAmount {
                        observer.onNext(transactions)
                    } else {
                        let remainder = totalTransactionAmount - amount
                        if remainder > 0 {
                            observer.onError(ExpenseServiceError.failedToValidate(message: "Total amount is more by \(remainder)."))
                        } else {
                            observer.onError(ExpenseServiceError.failedToValidate(message: "Total amount is less by \(abs(remainder))."))
                        }
                    }
                }
            }

            observer.onCompleted()
            return Disposables.create()
        })
    }
    // MARK: - Create Expense
    func createExpense(data: ExpenseData) {
        self.validate(data: data).flatMap { (data) in
            self.validate(transactions: self.transactions)
        }.flatMapLatest { (transactions) -> Observable<Expense> in
            if let expense = self.expense {
                return self.service.updateExpense(expense: expense,
                    title: data.title,
                    amount: data.amount,
                    lender: data.payPerson,
                    createdAt: data.createdDate,
                    transactions: transactions,
                    group: self.group)
            } else {
                return self.service.createExpense(title: data.title,
                    amount: data.amount,
                    lender: data.payPerson,
                    createdAt: data.createdDate,
                    transactions: transactions,
                    group: self.group)
            }
        }.subscribe(onNext: { (expense) in
            self.sceneCoordinator.pop()
        }, onError: { (error) in
                self.errorsSubject.onNext(error)
            }).disposed(by: self.disposeBag)
    }

    // MARK: - Form
    func createForm() {
        self.form.removeAll()
        self.form
            +++ Section("Basic details")
        <<< TextRow() {
            $0.title = "Title"
            $0.add(rule: RuleRequired())
            $0.placeholder = "Enter title here"
            $0.validationOptions = .validatesOnChange
            if let expense = self.expense {
                $0.value = expense.title
            }

            $0.rx.value.bind(to: titleVariable).disposed(by: self.disposeBag)
            
        }.cellUpdate { cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .red
            }
        }
        <<< DecimalRow() {
            $0.title = "Amount"
            $0.add(rule: RuleRequired())
            $0.formatter = DecimalFormatter()
            $0.useFormatterDuringInput = true
            $0.placeholder = "Enter amount here"
            $0.validationOptions = .validatesOnChange
            $0.value = amountVariable.value
            $0.rx.value.bind(to: amountVariable).disposed(by: self.disposeBag)
        }.cellUpdate { cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .red
            }
        }
        <<< DateRow() {
            $0.title = "Date"
            $0.add(rule: RuleRequired())
            $0.value = createdAtVariable.value
            $0.rx.value.bind(to: createdAtVariable).disposed(by: self.disposeBag)
        }
            +++ Section(header: "People who pay", footer: "Click to choose person who should pay")
        <<< ActionSheetRow<Person>() {
            $0.title = "By"
            $0.selectorTitle = "People who pay"
            $0.options = self.group.members.toArray()
            $0.add(rule: RuleRequired())
            $0.displayValueFor = { (rowValue: Person?) in
                return rowValue?.name
            }
            if let expense = self.expense {
                $0.value = expense.lender
            }
        }.onPresent { from, to in
            to.popoverPresentationController?.permittedArrowDirections = .up
        }.onChange { (row) in
            if let value = row.value {
                self.whoPayChangedObserver.onNext(value)
            }
        }.cellUpdate { cell, row in
            if !row.isValid {
                cell.textLabel?.textColor = .red
            }
        }
            +++ self.transactionsSection
    }
    var transactionsSection: Section {
        let section = Section(header: "People who should pay", footer: "Click on money to edit. Total money must equal to amount.")

        let rows = self.transactions.enumerated().map { (index, transaction) -> DecimalRow in
            return DecimalRow() {
                $0.title = transaction.lendee?.name
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                $0.value = transaction.amount
                $0.formatter = DecimalFormatter()
                $0.useFormatterDuringInput = true
            }.onChange({ (row) in
                if let value = row.value {
                    self.transactions[self.transactions.index(self.transactions.startIndex, offsetBy: index)].amount = value
                }
            }).cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
        }
        self.transactionRows = rows
        rows.forEach { (row) in
            section.append(row)
        }
        return section
    }
}

