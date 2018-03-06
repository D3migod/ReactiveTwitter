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
        image = UIImage(named: "placeholder")
        if let cachedImage = ImageCache.shared.getImage(with: url as AnyObject) {
            image = cachedImage
        } else {
            guard let url = url else { return }
            getImageDownloadSignalProducer(url, stopLoadingSignal: stopLoadingSignal)
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
            .flatMap(.merge) { data, _ in
                return SignalProducer<UIImage, NoError> { observer, _ in
                    guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? UIImage, let result = json else {
                        observer.sendCompleted()
                        return
                    }
                    observer.send(value: result)
                    observer.sendCompleted()
                }
            }
            .take(until: stopLoadingSignal)
    }
}
