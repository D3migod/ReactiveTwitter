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
    case invalidToken
    case invalidUrl
    case serverFailed
    case failed
}

protocol TwitterAPIProtcol {
    static func getTweetList(for query: Query) -> (AccessToken) -> SignalProducer<Data, NetworkError>
}

struct TwitterAPI: TwitterAPIProtcol {
    
    
    fileprivate enum Address: String {
        case search = "search/tweets.json"
        
        private var baseURL: String { return "https://api.twitter.com/1.1/" }
        
        var url: URL? {
            return URL(string: baseURL.appending(rawValue))
        }
    }
    
    static func getTweetList(for query: Query) -> (AccessToken) -> SignalProducer<Data, NetworkError> {
        let ((minId, maxId, count), hashtag) = query
        return { account in
            var parameters = ["q": "#\(hashtag)",
                "result_type": "mixed",
                "count": String(count),
                "include_entities": "true"]
            if let minIdUnwrapped = minId {
                parameters["since_id"] = String(minIdUnwrapped)
            }
            if let maxIdUnwrapped = maxId {
                parameters["max_id"] = String(maxIdUnwrapped)
            }
            return request(account,
                           address: TwitterAPI.Address.search,
                           parameters: parameters)
        }
    }
    
    
    // MARK: - generic request to send an SLRequest
    static private func request(_ token: AccessToken, address: Address, parameters: [String: String] = [:]) -> SignalProducer<Data, NetworkError> {
        guard let request = createAuthorizedRequest(token, address: address, parameters: parameters) else {
            return SignalProducer<Data, NetworkError> { observer, _ in
                observer.send(error: NetworkError.invalidUrl)
            }
        }
        return performRequest(by: request)
    }
    
    static func performRequest(by request: URLRequest) -> SignalProducer<Data, NetworkError> {
        return URLSession.shared.reactive
            .data(with: request)
            .retry(upTo: 2)
            .mapError { _ in NetworkError.failed }
            .flatMap(.latest) { data, response  -> SignalProducer<Data, NetworkError> in
                return SignalProducer<Data, NetworkError> { observer, _ in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        observer.send(error: .failed)
                        return
                    }
//                    print(String(data: data, encoding: .utf8) ?? "No data")
                    if 200 ..< 300 ~= httpResponse.statusCode {
                        observer.send(value: data)
                        observer.sendCompleted()
                        return
                    } else if 400 == httpResponse.statusCode {
                        observer.send(error: .invalidToken)
                        return
                    } else if 401 ..< 500 ~= httpResponse.statusCode {
                        observer.send(error: .failed)
                        return
                    } else {
                        observer.send(error: .serverFailed)
                        return
                    }
                }
            }
            .on(failed: { error in
                switch error {
                case .invalidToken:
                    TwitterAccount.shared.token = nil
                    TwitterAccount.shared.account.start()
                default:
                    break
                }
            })
    }
    
    static private func createAuthorizedRequest(_ token: AccessToken, address: Address, parameters: HTTPParameters = [:]) -> URLRequest? {
        return createRequest(address.url, parameters: parameters, headers: ["Authorization": "Bearer \(token)"])
    }
    
    static func createRequest(_ url: URL?, parameters: HTTPParameters? = nil, bodyParameters: String? = nil, headers: HTTPHeaders, method: HTTPRequestMethod = .get) -> URLRequest? {
        guard let unwrappedUrl = url, var comps = URLComponents(string: unwrappedUrl.absoluteString) else {
            print("Incorrect url \(String(describing: url))")
            return nil
        }
        if let parameters = parameters {
            comps.queryItems = parameters.map(URLQueryItem.init)
        }
        guard let compsUrl = comps.url else {
            print("Incorrect parameters \(parameters ?? [:]) or url \(unwrappedUrl)")
            return nil
        }
        
        var request = URLRequest(url: compsUrl)
        if let bodyParameters = bodyParameters {
            request.httpBody = bodyParameters.data(using: .utf8)
        }
        request.httpMethod = method.rawValue
        headers.forEach({request.setValue($0.1, forHTTPHeaderField: $0.0)})
        return request
    }
}
