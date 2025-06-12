//
//  Transaction+JSON.swift
//  Finance ShMR
//
//  Created by Egor Herdziy on 11.06.25.
//

import Foundation

extension Transaction {
    
    static func parse(jsonObject: Any) -> Transaction? {
        guard
            let dict = jsonObject as? [String: Any],
            let idString = dict["id"] as? String,
            let id = UUID(uuidString: idString),
            let categoryIdString = dict["categoryId"] as? String,
            let categoryId = UUID(uuidString: categoryIdString),
            let amountNumber = dict["amount"] as? NSNumber,
            let transactionDateTimestamp = dict["transactionDate"] as? TimeInterval,
            let createdAtTimestamp = dict["createdAt"] as? TimeInterval,
            let updatedAtTimestamp = dict["updatedAt"] as? TimeInterval
        else {
            return nil
        }

        let comment = dict["comment"] as? String

        return Transaction(
            id: id,
            categoryId: categoryId,
            amount: amountNumber.decimalValue,
            transactionDate: Date(timeIntervalSince1970: transactionDateTimestamp),
            comment: comment,
            createdAt: Date(timeIntervalSince1970: createdAtTimestamp),
            updatedAt: Date(timeIntervalSince1970: updatedAtTimestamp)
        )
    }

    var jsonObject: Any {
        var dict: [String: Any] = [
            "id": id.uuidString,
            "categoryId": categoryId.uuidString,
            "amount": NSDecimalNumber(decimal: amount),
            "transactionDate": transactionDate.timeIntervalSince1970,
            "createdAt": createdAt.timeIntervalSince1970,
            "updatedAt": updatedAt.timeIntervalSince1970
        ]
        if let comment = comment {
            dict["comment"] = comment
        }
        return dict
    }
}

