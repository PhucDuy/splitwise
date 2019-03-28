//
//  Eureka+Rx.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/28/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import Foundation
import Eureka
import RxSwift
import RxCocoa
extension RowOf: ReactiveCompatible { }

extension Reactive where Base: RowType, Base: BaseRow {
    var value: ControlProperty<Base.Cell.Value?> {
        let source = BehaviorRelay<Base.Cell.Value?>.create { observer in
            self.base.onChange { row in
                observer.onNext(row.value)
            }
            return Disposables.create()
        }

        let bindingObserver = Binder(self.base) { (row, value) in
            row.value = value
        }
        return ControlProperty(values: source, valueSink: bindingObserver)
    }
}
