//
//  UIImageView+loadImage.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 05.03.2018.
//  Copyright © 2018 Bulat. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result

extension UIImageView {
    func setImage(_ url: URL?, stopLoadingSignal: Signal<(), NoError>) {
        image = #imageLiteral(resourceName: "twitter_placeholder")
        if let cachedImage = ImageCache.shared.getImage(with: url as AnyObject) {
            image = cachedImage
        } else {
            guard let url = url else { return }
            getImageDownloadSignalProducer(url, stopLoadingSignal: stopLoadingSignal)
                .observe(on: UIScheduler())
                .startWithValues { [weak self] gotImage in
                    self?.image = gotImage
                }
        }
    }
    
    fileprivate func getImageDownloadSignalProducer(_ url: URL, stopLoadingSignal: Signal<(), NoError>) -> SignalProducer<UIImage, NoError> {
        let urlRequest = URLRequest(url: url)
        return URLSession.shared.reactive
            .data(with: urlRequest)
            .retry(upTo: 2)
            .flatMapError  { _ in SignalProducer.empty }
            .flatMap(.latest) { data, _ in
                return SignalProducer<UIImage, NoError> { observer, _ in
                    guard let image = UIImage(data: data) else {
                        observer.sendCompleted()
                        return
                    }
                    observer.send(value: image)
                    observer.sendCompleted()
                }
            }
            .take(until: stopLoadingSignal)
    }
}
