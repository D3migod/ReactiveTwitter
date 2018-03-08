//
//  TweetListPresenter.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 05.03.18.
//  Copyright © 2018 Bulat. All rights reserved.
//

import Foundation
import ReactiveSwift

class TweetListPresenter: TweetListPresenterProtocol {
    
    var interactor: TweetListInteractorProtocol!
    
    var wireFrame: TweetListWireFrameProtocol!
    
    // MARK: - Input
    var paused: Bool = false {
        didSet {
            interactor.paused.value = paused
        }
    }
    
    // MARK: - Output
    var tweets: MutableProperty<[Tweet]>! //private(set)
    var loggedIn: MutableProperty<Bool>!
    
    init(interactor: TweetListInteractorProtocol,
         wireFrame: TweetListWireFrameProtocol) {
        self.interactor = interactor
        self.wireFrame = wireFrame
        
        // Subscribe to interactor changes of tweets (in local database)
        tweets <~ interactor.tweetsProducer
        // Subscribe to interactor changes of account visibility
        loggedIn <~ interactor.account 
    }
    
    
}
