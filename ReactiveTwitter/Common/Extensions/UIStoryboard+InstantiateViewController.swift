//
//  Storyboard+InstantiateViewController.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 08.03.2018.
//  Copyright © 2018 Bulat. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {
    
    /// Instantiates ViewController by its class name. It must be equal to viewController's identifier.
    func instantiateViewController<T>(ofType type: T.Type) -> T {
        return instantiateViewController(withIdentifier: String(describing: type)) as! T
    }
}
