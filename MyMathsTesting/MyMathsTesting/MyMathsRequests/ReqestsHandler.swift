//
//  ReqestsHandler.swift
//  MyMathsTesting
//
//  Created by Amy While on 01/02/2022.
//

import Foundation

public final class RequestsHandler {
    
    static let sessionManager: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.httpShouldSetCookies = true
        configuration.httpCookieAcceptPolicy = .always
        return URLSession(configuration: configuration, delegate: RequestsHandlerDelegate.shared, delegateQueue: OperationQueue())
    }()
    
    public typealias Response<T: Any> = ((Bool, Int?, Error?, T?) -> Void)

    class public func request<T: Any>(request: URLRequest, type: T.Type, _ completion: @escaping Response<T>) {
        sessionManager.dataTask(with: request) { data, response, error -> Void in
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            let location: String? = (response as? HTTPURLResponse)?.allHeaderFields["location"] as? String
            var returnData: T?
            var success: Bool = false
            if let data = data {
                if T.self == Data.self {
                    returnData = data as? T
                    success = true
                } else if let decoded = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? T {
                    returnData = decoded
                    success = true
                }
            }
            return completion(success, statusCode, error, returnData)
        }.resume()
    }

    class public func request<T: Any>(url: String?, type: T.Type, method: String = "GET", headers: [String: String] = [:], json: [String: AnyHashable?]? = nil, multipart: [[String: Data]]? = nil, form: [String: AnyHashable]? = nil, _ completion: @escaping Response<T>) {
        guard let _url = url,
              let url = URL(string: _url) else { return completion(false, nil, nil, nil) }
        request(url: url, type: type, method: method, headers: headers, json: json, multipart: multipart, form: form, completion)
    }

    class public func request<T: Any>(url: URL, type: T.Type, method: String = "GET", headers: [String: String] = [:], json: [String: AnyHashable?]? = nil, multipart: [[String: Data]]? = nil, form: [String: AnyHashable]? = nil, _ completion: @escaping Response<T>) {
        var request = URLRequest(url: url, timeoutInterval: 30)
        request.httpMethod = method
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        if let json = json,
                  !json.isEmpty,
                  let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
           request.httpBody = jsonData
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } else if let form = form {
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            guard let bodyString = form.map({ "\($0.key)=\($0.value)" }).joined(separator: "&").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                return completion(false, nil, nil, nil)
            }
            request.httpBody = bodyString.data(using: .utf8)
        }
        Self.request(request: request, type: type, completion)
    }
    
}

fileprivate class RequestsHandlerDelegate: NSObject, URLSessionTaskDelegate {
    
    public static let shared = RequestsHandlerDelegate()

        
}
