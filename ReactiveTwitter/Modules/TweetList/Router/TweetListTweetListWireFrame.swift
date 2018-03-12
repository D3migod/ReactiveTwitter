//
//  TweetListRouter.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 05.03.18.
//  Copyright © 2018 Bulat. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

class TweetListWireFrame: TweetListWireFrameProtocol {
    
    struct StoryboardIdentifiers {
        static let main = "Main"
    }
    
    struct ViewControllerIdentifiers {
        static let tweetListNavigation = "TweetListNavigationViewController"
    }
    
    class func createConnections(account: SignalProducer<TwitterAccount.AccountStatus, NoError>) -> UIViewController {
        let wireFrame = TweetListWireFrame()
        let localDataManager: TweetListLocalDataManagerProtocol = TweetListLocalDataManager()
        let remoteDataManager: TweetListRemoteDataManagerProtocol =
            TweetListRemoteDataManager(account: account)
        let interactor: TweetListInteractorProtocol =
            TweetListInteractor(localDatamanager: localDataManager,
                                remoteDatamanager: remoteDataManager,
                                account: account)
        let presenter: TweetListPresenterProtocol =
            TweetListPresenter(interactor: interactor,
                               wireFrame: wireFrame)
        let view = TweetListView.createWith(
            storyboard: TweetListWireFrame.mainStoryboard,
            presenter: presenter)
        guard let navigationController = mainStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.tweetListNavigation) as? UINavigationController else {
            return UIViewController()
        }
        navigationController.pushViewController(view, animated: false)
        return navigationController
    }
    
    static var mainStoryboard: UIStoryboard {
        return UIStoryboard(name: StoryboardIdentifiers.main, bundle: Bundle.main)
    }
}
