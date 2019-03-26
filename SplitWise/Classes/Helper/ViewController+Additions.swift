//
//  ViewController+Additions.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/26/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import UIKit
import RxSwift

extension UIViewController {
    func alert(_ title: String, description: String? = nil) -> Completable {
        return Completable.create(subscribe: { [unowned self] (complete) -> Disposable in
            let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: {
                _ in
                complete(.completed)
            }))
            
            self.present(alert, animated: true, completion: nil)
            return Disposables.create()
        })
    }
}
