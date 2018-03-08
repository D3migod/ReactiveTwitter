//
//  TwitterAPI.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 05.03.18.
//  Copyright © 2018 Bulat. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

typealias JSONObject = [String: Any]
typealias AccessToken = String
typealias HTTPParameters = [String: String]
typealias HTTPHeaders = [String: String]

enum HTTPRequestMethod: String {
    case get = "GET"
    case post = "POST"
}

enum NetworkError: Error {
    case invalidUrl
    case failed
}

protocol TwitterAPIProtcol {
    static func getTweetList(for hashtag: String) -> (AccessToken, TweetListCursor) -> SignalProducer<Data, NetworkError>
}

struct TwitterAPI: TwitterAPIProtcol {
    
    fileprivate enum Address: String {
        case search = "search/tweets.json"
        
        private var baseURL: String { return "https://api.twitter.com/1.1/" }
        
        var url: URL? {
            return URL(string: baseURL.appending(rawValue))
        }
    }
    
    static func getTweetList(for hashtag: String) -> (AccessToken, TweetListCursor) -> SignalProducer<Data, NetworkError> {
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
        guard let request = createAuthorizedRequest(token, address: address, parameters: parameters) else {
            return SignalProducer<T, NetworkError> { observer, _ in
                observer.send(error: NetworkError.invalidUrl)
            }
        }
        return performRequest(by: request)
    }
    
    static func performRequest<T: Any>(by request: URLRequest) -> SignalProducer<T, NetworkError> {
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
    
    static private func createAuthorizedRequest(_ token: AccessToken, address: Address, parameters: HTTPParameters = [:]) -> URLRequest? {
        return createRequest(address.url, parameters: parameters, headers: ["Bearer \(token)": "Authorization"])
    }
    
    static func createRequest(_ url: URL?, parameters: HTTPParameters, headers: HTTPHeaders, method: HTTPRequestMethod = .get) -> URLRequest? {
        guard let unwrappedUrl = url, var comps = URLComponents(string: unwrappedUrl.absoluteString) else {
            print("Incorrect url \(String(describing: url))")
            return nil
        }
        comps.queryItems = parameters.map(URLQueryItem.init)
        guard let compsUrl = comps.url else {
            print("Incorrect parameters \(parameters)")
            return nil
        }
        var request = URLRequest(url: compsUrl)
        request.httpMethod = method.rawValue
        headers.forEach({request.setValue($0.0, forHTTPHeaderField: $0.1)})
        return request
    }
}
