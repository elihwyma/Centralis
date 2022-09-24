//
//  Edulink_Catering.swift
//  Centralis
//
//  Created by Somica on 02/03/2022.
//

import Foundation
import Evander
import SerializedSwift
import StoreKit

public final class Catering: Serializable {
    
    public init() {
        
    }
    
    @Serialized var balance: Double
    @Serialized(default: []) var transactions: [Transaction]
    
    public var stringBalance: String {
        String(format: "£%.2f", balance)
    }
    
    init(balance: Double, transactions: [Transaction]) {
        self.balance = balance
        self.transactions = transactions
    }
    
    public final class Transaction: Serializable, Equatable {
        @SerializedTransformable<DateConverter> var date: Date?
        @Serialized(default: []) var items: [Item]
        
        struct Item: Serializable {
            @Serialized var item: String
            @Serialized var price: Double
            
            public var stringPrice: String {
                String(format: "£%.2f", abs(price)) 
            }
        }
        
        init(date: Date, items: [Item]) {
            self.date = date
            self.items = items
        }
        
        required public init() {}
    }

    public class func updateCatering(_ completion: @escaping (String?, Catering?) -> Void) {
        EvanderNetworking.edulinkDict(method: "EduLink.Catering", params: []) { _, _, error, result in
            guard PermissionManager.contains(.catering) else { return completion(nil, Catering(balance: 0.0, transactions: [])) }
            guard let result = result,
                  let jsonResult = try? JSONSerialization.data(withJSONObject: result) else { return completion(error ?? "Unknown Error", nil) }
            do {
                let catering = try JSONDecoder().decode(Catering.self, from: jsonResult)
                var items = [Date: [Transaction.Item]]()
                for transaction in catering.transactions where transaction.date != nil {
                    let date = transaction.date!
                    if let transactionItems = items[date] {
                        items[date] = transactionItems + transaction.items
                    } else {
                        items[date] = transaction.items
                    }
                }
                let transactions = items.map { Transaction(date: $0.key, items: $0.value) }
                catering.transactions = transactions
                PersistenceDatabase.CateringDatabase.saveCatering(catering: catering)
                completion(error, catering)
            } catch {
                return completion(error.localizedDescription, nil)
            }
        }
    }
}

public func ==(lhs: Catering.Transaction, rhs: Catering.Transaction) -> Bool {
    lhs.date == rhs.date
}
