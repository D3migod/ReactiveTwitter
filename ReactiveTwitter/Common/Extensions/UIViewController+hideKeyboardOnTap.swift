//
//  UIViewController+HideKeyboard.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 16.03.2018.
//  Copyright © 2018 Bulat. All rights reserved.
//

import UIKit

extension UIViewController {
    func hideKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboardAction))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboardAction() {
        view.endEditing(true)
    }
}
