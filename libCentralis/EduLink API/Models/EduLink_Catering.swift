//
//  EduLink_Catering.swift
//  Centralis
//
//  Created by AW on 02/12/2020.
//

import Foundation

/// A model for working with Catering
public class EduLink_Catering {
    /// Retrieve the balance and transactions of a user. For more documentation see `Catering`
    /// - Parameter rootCompletion: The completion handler, for more documentation see `completionHandler`
    class public func catering(learnerID: String = EduLinkAPI.shared.authorisedUser.id, _ rootCompletion: @escaping completionHandler) {
        let params: [String : AnyEncodable] = [
            "learner_id" : AnyEncodable(learnerID)
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.Catering", params: params, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            var catering = Catering()
            catering.balance = result["balance"] as? Double ?? 0.0
            catering.transactions.removeAll()
            if let transactions = result["transactions"] as? [[String : Any]] {
                for transaction in transactions {
                    var cateringTransaction = CateringTransaction()
                    cateringTransaction.id = "\(transaction["id"] ?? "Not Given")"
                    cateringTransaction.date = transaction["date"] as? String ?? "Not Given"
                    let items = transaction["items"] as? [[String : Any]] ?? [[String : Any]]()
                    for item in items {
                        var cateringItem = CateringItem()
                        cateringItem.item = item["item"] as? String ?? "Not Given"
                        cateringItem.price = item["price"] as? Double ?? 0.0
                        cateringTransaction.items.append(cateringItem)
                    }
                    catering.transactions.append(cateringTransaction)
                }
            }
            if EduLinkAPI.shared.authorisedUser.id == learnerID { EduLinkAPI.shared.catering = catering } else {
                if let index = EduLinkAPI.shared.authorisedUser.children.firstIndex(where: {$0.id == learnerID}) {
                    EduLinkAPI.shared.authorisedUser.children[index].catering = catering
                }
            }
            EduLinkAPI.shared.catering = catering
            return rootCompletion(true, nil)
        })
    }
}

/// A container for a CateringTransaction
public struct CateringTransaction {
    /// The ID of the transaction
    public var id: String!
    /// The date of the transaction
    public var date: String!
    /// The items that were purchased, for more documentation see `CateringItem`
    public var items = [CateringItem]()
}

/// A container for a CateringItem
public struct CateringItem {
    /// The item that was purchased
    public var item: String!
    /// The price of the item
    public var price: Double!
}

/// The container for Catering
public struct Catering {
    /// The balance of the user
    public var balance: Double!
    /// An array of transactions by the user, for more documentation see `CateringTransaction`
    public var transactions = [CateringTransaction]()
}
