//
//  MockTweetListWireFrame.swift
//  ReactiveTwitterTests
//
//  Created by Bulat Galiev on 17.03.2018.
//  Copyright © 2018 Bulat. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import Result

@testable import ReactiveTwitter

class MockTweetListWireFrame: TweetListWireFrameProtocol {
    static func createConnections(account: SignalProducer<TwitterAccount.AccountStatus, NoError>) -> UIViewController {
        return UIViewController()
    }
}
