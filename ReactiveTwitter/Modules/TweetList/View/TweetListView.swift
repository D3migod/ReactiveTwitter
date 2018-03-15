//
//  TweetListView.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 05.03.18.
//  Copyright © 2018 Bulat. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

class TweetListView: UIViewController, TweetListViewProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var messageView: UIView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var prefetchSignal: Signal<[Int], NoError>!
    
    var prefetchObserver: Signal<[Int], NoError>.Observer!
    
    var combinedIndexPaths: Signal<([Int], String?), NoError>!
    
    var presenter: TweetListPresenterProtocol!
    
    static func createWith(storyboard: UIStoryboard, presenter: TweetListPresenterProtocol) -> TweetListView {
        let tweetListView = storyboard.instantiateViewController(ofType: TweetListView.self)
        tweetListView.presenter = presenter
        return tweetListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        tableView.allowsSelection = false
        hideKeyboardOnTap()
        bindUI()
    }
    
    func bindUI() {
        let (prefetchSignal, prefetchObserver) = Signal<[Int], NoError>.pipe()
        self.prefetchSignal = prefetchSignal
        self.prefetchObserver = prefetchObserver
        tableView.reactive.reloadData <~ presenter.tweets.producer
            .map { _ in }
        // Clear table on empty text field bypassing throttle
        let emptyInputSignal = searchBar.reactive.continuousTextValues.filter({$0?.isEmpty ?? true}).map { ([Int](), $0) }
        let nonEmptyInputSignal = Signal
            .combineLatest(prefetchSignal, searchBar.reactive.continuousTextValues
                .throttle(0.5, on: QueueScheduler.main)
                .filter({!($0?.isEmpty ?? true)}))
            .combinePrevious(([], nil))
            .on(value: { [weak self] value in
                let (previousValue, currentValue) = value
                if previousValue.1 != currentValue.1 {
                    self?.presenter.tweets.value = []
                }
            })
            .map { value -> ([Int], String?) in
                let (previousValue, currentValue) = value
                return previousValue.1 != currentValue.1 ? ([], currentValue.1) : currentValue
            }
        
        Signal.merge(emptyInputSignal, nonEmptyInputSignal)
.observe(presenter.prefetchObserver)
        prefetchObserver.send(value: [])
        
        messageView.reactive.isHidden <~ presenter.loggedIn.producer
    }
}

extension TweetListView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TweetTableViewCell.self), for: indexPath) as! TweetTableViewCell
        
        cell.update(with: presenter.tweets.value[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.tweets.value.count
    }
//    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        prefetchObserver.send(value: [indexPath.row])
//    }
}



extension TweetListView: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        prefetchObserver.send(value: indexPaths.map{$0.row})
    }
}
