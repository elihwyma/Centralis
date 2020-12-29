//
//  NetworkManager.swift
//  Shade
//
//  Created by Amy While on 18/10/2020.
//

import Foundation

typealias completionHandler = (_ success: Bool, _ error: String?) -> ()

class NetworkManager {
    let emptyDict = [String : Any]()
    static let shared = NetworkManager()
    
    typealias requestDictCompletion = (_ success: Bool, _ dict: [String : Any]) -> ()
    
    public func generateStringFromDict(_ dict: [String : String]) -> String {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(dict) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        }
        return "Error"
    }
    
    public func requestWithDict(url: URL, method: String, headers: [String : String]?, jsonbody: String?, completion: @escaping requestDictCompletion) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = jsonbody?.data(using: .utf8)
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if let data = data {
                do {
                    let dict = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any] ?? [String : Any]()
                    completion(true, dict)

                } catch {
                    completion(false, self.emptyDict)
                }
            } else { completion(false, self.emptyDict) }
        }
        task.resume()
    }
}
