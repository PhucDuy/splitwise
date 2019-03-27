//
//  UIBarButtonItem.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/27/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import Foundation
import UIKit
import Action
import RxSwift
extension UIBarButtonItem {
    class func backButton() -> UIBarButtonItem {
        let customBackButton = UIBarButtonItem(image: UIImage(named: "ic_back"),
                                               style: .plain, target: nil, action: nil)
        customBackButton.tintColor = UIColor.white
        return customBackButton
    }
}
