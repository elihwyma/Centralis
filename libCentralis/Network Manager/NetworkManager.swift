//
//  NetworkManager.swift
//  libCentralis
//
//  Created by AW on 18/10/2020.
//

import Foundation

/// The completion handler used by every request in the library
/// - Parameters:
///   - success: If the API request was succesful
///   - error: The error code returned from EduLink
public typealias completionHandler = (_ success: Bool, _ error: String?) -> ()
internal typealias rdc = (_ success: Bool, _ dict: [String : Any]) -> ()

internal class NetworkManager {

    internal func generateStringFromDict(_ dict: [String : String]) -> String {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(dict) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        }
        return "Error"
    }
    
    class internal func requestWithDict(url: String?, requestMethod: String, params: [String: AnyEncodable] = [:], completion: @escaping rdc) {
        var c = URLComponents(string: url ?? EduLinkAPI.shared.authorisedSchool.server!)!
        c.queryItems = [URLQueryItem(name: "method", value: requestMethod)]
        var request = URLRequest(url: c.url!)
        request.httpMethod = "POST"
        let b = EdulinkBody(method: requestMethod, params: params)
        guard let jd = try? JSONEncoder().encode(b) else { return completion(false, [String : Any]())}
        request.httpBody = jd
        request.setValue(requestMethod, forHTTPHeaderField: "x-api-method")
        request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        if let auth = EduLinkAPI.shared.authorisedUser.authToken { request.setValue("Bearer \(auth)", forHTTPHeaderField: "Authorization") }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if let data = data {
                do {
                    let dict = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any] ?? [String : Any]()
                    completion(true, dict)
                } catch {
                    completion(false, [String : Any]())
                }
            } else { completion(false, [String : Any]()) }
        }
        task.resume()
    }
}

/// The request body that is sent with every request to EduLink
fileprivate struct EdulinkBody: Encodable {
    /// The current json version
    var jsonrpc = "2.0"
    /// The query method curently being posted
    var method: String
    /// The random UUID that is sent with every request, for more documentation see `UUID`
    var uuid = UUID.uuid
    /// The ID of the request, 1 every time works fine
    var id = "1"
    /// The specific request parameters, usually containing authtoken
    var params: [String: AnyEncodable]
    
    /// The initialiser for the struct. This is used to generate the json body.
    /// - Parameters:
    ///   - method: The query method
    ///   - params: The query parameters
    init(method: String, params: [String: AnyEncodable]) {
        self.method = method
        self.params = params
    }
}

struct AnyEncodable: Encodable {

    private let _encode: (Encoder) throws -> Void
    public init<T: Encodable>(_ wrapped: T) {
        _encode = wrapped.encode
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
