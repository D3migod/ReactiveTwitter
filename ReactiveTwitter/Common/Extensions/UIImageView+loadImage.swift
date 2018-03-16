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
    
    // MARK: - Functions
    
    /**
     Load and set image
     
     - Parameter url: url to load image by
     
     - Parameter stopLoadingSignal: signal aborting load (if imageView is no longer visible)
     */
    func setImage(_ url: URL?, stopLoadingSignal: Signal<(), NoError>) {
        if let cachedImage = ImageCache.shared.getImage(with: url as AnyObject) {
            image = cachedImage
        } else {
            image = #imageLiteral(resourceName: "twitter_placeholder")
            guard let url = url else { return }
            getImageDownloadSignalProducer(url, stopLoadingSignal: stopLoadingSignal)
                .observe(on: UIScheduler())
                .startWithValues { [weak self] gotImage in
                    self?.image = gotImage
                    ImageCache.shared.saveImage(gotImage, identifier: url as AnyObject)
                }
        }
    }
    
    /**
     Load image by url
     
     - Parameter url: url to load image by
     
     - Parameter stopLoadingSignal: signal aborting load (if imageView is no longer visible)
     */
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
