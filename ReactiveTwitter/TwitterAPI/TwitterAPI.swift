//
//  TwitterAPI.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 05.03.18.
//  Copyright © 2018 Bulat. All rights reserved.
//

import Foundation
import ReactiveSwift

typealias JSONObject = [String: Any]
typealias AccessToken = String

enum NetworkError: Error {
    case invalidUrl
    case failed
}

protocol TwitterAPIProtcol {
    static func getTweetList(for hashtag: String) -> (AccessToken, TweetListCursor) -> Signal<[JSONObject], NetworkError>
}

struct TwitterAPI {
    
    fileprivate enum Address: String {
        case search = "search/tweets.json"
        
        private var baseURL: String { return "https://api.twitter.com/1.1/" }
        
        var url: URL? {
            return URL(string: baseURL.appending(rawValue))
        }
    }
    
    static func getTweetList(for hashtag: String) -> (AccessToken, TweetListCursor) -> SignalProducer<[JSONObject], NetworkError> {
        return { account, cursor in
            return request(account,
                           address: TwitterAPI.Address.search,
                           parameters: ["q": "%23\(hashtag)",
                                        "result_type": "mixed",
                                        "count": "100",
                                        "include_entities": "true"])
        }
    }
    
    
    // MARK: - generic request to send an SLRequest
    static private func request<T: Any>(_ token: AccessToken, address: Address, parameters: [String: String] = [:]) -> SignalProducer<T, NetworkError> {
        guard let request = makeRequest(token, address: address, parameters: parameters) else {
            return SignalProducer<T, NetworkError> { observer, _ in
                observer.send(error: NetworkError.invalidUrl)
            }
        }
        return URLSession.shared.reactive
            .data(with: request)
            .retry(upTo: 2)
            .mapError { _ in NetworkError.failed }
            .flatMap(.merge) { data, _  -> SignalProducer<T, NetworkError> in
                return SignalProducer<T, NetworkError> { observer, _ in
                    guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? T, let result = json else {
                        observer.send(error: NetworkError.failed)
                        return
                    }
                    observer.send(value: result)
                    observer.sendCompleted()
                }
        }
    }
    
    static private func makeRequest(_ token: AccessToken, address: Address, parameters: [String: String] = [:]) -> URLRequest? {
        guard let addressUrl = address.url, var comps = URLComponents(string: addressUrl.absoluteString) else {
            print("Incorrect url \(String(describing: address.url))")
            return nil
        }
        comps.queryItems = parameters.map(URLQueryItem.init)
        guard let compsUrl = comps.url else {
            print("Incorrect parameters \(parameters)")
            return nil
        }
        var request = URLRequest(url: compsUrl)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
