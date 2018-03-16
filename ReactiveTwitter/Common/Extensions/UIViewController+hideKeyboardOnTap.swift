//
//  UIViewController+HideKeyboard.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 16.03.2018.
//  Copyright © 2018 Bulat. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /// Hides keyboard on any press outside keyboard
    func hideKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboardAction))
        view.addGestureRecognizer(tapGesture)
    }
    
    /// Hides keyboard
    @objc func hideKeyboardAction() {
        view.endEditing(true)
    }
}
