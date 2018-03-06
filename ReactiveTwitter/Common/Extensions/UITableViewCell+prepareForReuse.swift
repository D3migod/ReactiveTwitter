//
//  UITableViewCell+prepareForReuse.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 05.03.2018.
//  Copyright © 2018 Bulat. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

extension UITableViewCell {
    func prepareForReuseSignal() -> Signal<(), NoError> {
        return Signal { observer, _ in
            self.prepareForReuseSignal()
                .producer
                .map { _ in () }
                .promoteError(NoError.self)
                .start(observer)
        }
    }
}
