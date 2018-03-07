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
    
    weak var view: TweetListViewProtocol!
    
    var interactor: TweetListInteractorProtocol!
    
    var wireFrame: TweetListWireFrameProtocol!
    
    // MARK: - Input
    var paused: Bool = false {
        didSet {
            interactor.paused.value = paused
        }
    }
    
    // MARK: - Output
    var tweets: MutableProperty<[Tweet]>!
    var loggedIn: MutableProperty<Bool>!
    
    init(view: TweetListViewProtocol,
         interactor: TweetListInteractorProtocol,
         wireFrame: TweetListWireFrameProtocol) {
        self.view = view
        self.interactor = interactor
        self.wireFrame = wireFrame
        
        // Subscribe to interactor changes of tweets (in local database)
        tweets <~ interactor.tweetsProducer
        // Subscribe to interactor changes of account visibility
        loggedIn <~ interactor.account 
    }
    
    
}
