//
//  EdulinkRequests.swift
//  Centralis
//
//  Created by Andromeda on 22/11/2021.
//

import Foundation
import Evander

public extension EvanderNetworking {
    
    class func request<T: Any>(url: URL, type: T.Type = [String: Any].self as! T.Type, method: String, params: [EdulinkParameters], _ completion: @escaping ((Bool, Int?, Error?, T?) -> Void)) {
        var url = URLComponents(string: url.absoluteString)!
        url.queryItems = [URLQueryItem(name: "method", value: method)]
        var request = URLRequest(url: url.url!, timeoutInterval: 30)
        request.setValue(method, forHTTPHeaderField: "x-api-method")
        request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        guard let encoded = generateBody(method: method, params: params) else { return completion(false, nil, "Failed to Encode JSON Body", nil) }
        request.httpBody = encoded
        request.httpMethod = "POST"
        self.request(request: request, type: type, cache: .init(localCache: false, skipNetwork: false), completion)
    }
        
    class func request<T: Any>(type: T.Type = [String: Any].self as! T.Type, method: String, params: [EdulinkParameters], _ completion: @escaping ((Bool, Int?, Error?, T?) -> Void)) {
        guard let authenticatedUser = EdulinkManager.shared.authenticatedUser,
              let login = authenticatedUser.login else { return completion(false, nil, "No User is Currently Logged in", nil) }
        var url = URLComponents(string: login.server.absoluteString)!
        url.queryItems = [URLQueryItem(name: "method", value: method)]
        var request = URLRequest(url: url.url!, timeoutInterval: 30)
        request.setValue(method, forHTTPHeaderField: "x-api-method")
        request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authenticatedUser.authtoken)", forHTTPHeaderField: "Authorization")
        
        guard let encoded = generateBody(method: method, params: params) else { return completion(false, nil, "Failed to Encode JSON Body", nil) }
        request.httpBody = encoded
        request.httpMethod = "POST"
        self.request(request: request, type: type, cache: .init(localCache: true, skipNetwork: false), completion)
    }
    
    class func edulinkDict(method: String, params: [EdulinkParameters], _ completion: @escaping ((Bool, Int?, String?, [String: Any]?) -> Void)) {
        request(type: [String: Any].self, method: method, params: params) { success, code, error, dict in
            guard success,
                  let dict = dict else {
                return completion(false, code, error?.localizedDescription ?? "Failed to Connect to EduLink", nil)
            }
            guard let result = dict["result"] as? [String: Any] else {
                return completion(false, code, "Failed to Parse Response", nil)
            }
            if !(result["success"] as? Bool ?? false) {
                return completion(false, code, result["error"] as? String ?? "Unknown Error", nil)
            }
            completion(true, code, nil, result)
        }
    }
    
    class func edulinkDict(url: URL, method: String, params: [EdulinkParameters], _ completion: @escaping ((Bool, Int?, String?, [String: Any]?) -> Void)) {
        request(url: url, type: [String: Any].self, method: method, params: params) { success, code, error, dict in
            guard success,
                  let dict = dict else {
                return completion(false, code, error?.localizedDescription ?? "Failed to Connect to EduLink", nil)
            }
            guard let result = dict["result"] as? [String: Any] else {
                return completion(false, code, "Failed to Parse Response", nil)
            }
            if !(result["success"] as? Bool ?? false) {
                return completion(false, code, result["error"] as? String ?? "Unknown Error", nil)
            }
            completion(true, code, nil, result)
        }
    }
    
    class private func generateBody(method: String, params: [EdulinkParameters]) -> Data? {
        var dict = [String: AnyHashable]()
        for param in params {
            if let value = param.value {
               dict[param.key] = value
            }
        }
        let body: [String: AnyHashable] = [
            "jsonrpc": "2.0",
            "method": method,
            "uuid": UUID().uuidString,
            "id": "1",
            "params": dict
        ]
        return try? JSONSerialization.data(withJSONObject: body)
    }
}

public enum EdulinkParameters {
    
    case learner_id
    case format(value: Int)
    case custom(key: String, value: AnyHashable)
    
    public var key: String {
        switch self {
        case .learner_id: return "learner_id"
        case .format: return "format"
        case .custom(let key, _): return key
        }
    }
    
    public var value: AnyHashable? {
        switch self {
        case .learner_id: return EdulinkManager.shared.authenticatedUser?.learner_id
        case .format(let value): return value
        case .custom(_, let value): return value
        }
    }
}

fileprivate struct AnyEncodable: Encodable {

    private let _encode: (Encoder) throws -> Void
    
    public init?(_ wrapper: AnyHashable) {
        if let wrapper = wrapper as? String {
            _encode = wrapper.encode
        } else if let wrapper = wrapper as? Int {
            _encode = wrapper.encode
        } else if let wrapper = wrapper as? Bool {
            _encode = wrapper.encode
        } else { return nil }
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
