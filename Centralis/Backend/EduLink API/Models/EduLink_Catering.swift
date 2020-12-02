//
//  EduLink_Catering.swift
//  Centralis
//
//  Created by Amy While on 02/12/2020.
//

import Foundation

class EduLink_Catering {
    
    public func catering() {
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.Catering")!
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.Catering\",\"params\":{\"last_visible\":0,\"authtoken\":\"\(EduLinkAPI.shared.authorisedUser.authToken!)\"},\"uuid\":\"\(UUID.shared.uuid)\",\"id\":\"1\"}"
        NetworkManager.shared.requestWithDict(url: url, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if success {
                print(dict)
                if let result = dict["result"] as? [String : Any] {
                    if !(result["success"] as! Bool) {
                        NotificationCenter.default.post(name: .FailedCatering, object: nil)
                        return
                    }
                    EduLinkAPI.shared.catering.balance = result["balance"] as? Double
                    EduLinkAPI.shared.catering.transactions.removeAll()
                    if let transactions = result["transactions"] as? [[String : Any]] {
                        for transaction in transactions {
                            var cateringTransaction = CateringTransaction()
                            cateringTransaction.id = transaction["id"] as? Int
                            cateringTransaction.date = transaction["date"] as? String
                            let items = transaction["items"] as? [[String : Any]] ?? [[String : Any]]()
                            for item in items {
                                var cateringItem = CateringItem()
                                cateringItem.item = item["item"] as? String
                                cateringItem.price = item["price"] as? Double
                                cateringTransaction.items.append(cateringItem)
                            }
                            EduLinkAPI.shared.catering.transactions.append(cateringTransaction)
                        }
                    }
                    NotificationCenter.default.post(name: .SuccesfulCatering, object: nil)
                } else {
                    NotificationCenter.default.post(name: .FailedCatering, object: nil)
                }
            } else {
                NotificationCenter.default.post(name: .NetworkError, object: nil)
            }
        })
    }
    
}
