//
//  Transaction+CSV.swift
//  Finance ShMR
//
//  Created by Egor Herdziy on 13.06.25.
//

import Foundation

extension Transaction {
    
    static func parse(csvLine: String) -> Transaction? {
        let components = csvLine.components(separatedBy: ",")
        guard components.count >= 7 else {
            return nil
        }
        
        let id = components[0]
        let categoryId = components[1]
        let amountString = components[2]
        let transactionDateString = components[3]
        let commentString = components[4]
        let createdAtString = components[5]
        let updatedAtString = components[6]
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard
            let amount = Decimal(string: amountString),
            let transactionDate = formatter.date(from: transactionDateString),
            let createdAt = formatter.date(from: createdAtString),
            let updatedAt = formatter.date(from: updatedAtString)
        else {
            return nil
        }
        
        return Transaction(
            id: id,
            categoryId: categoryId,
            amount: amount,
            transactionDate: transactionDate,
            comment: commentString.isEmpty ? nil : commentString,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    var csvLine: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let fields: [String] = [
            id,
            categoryId,
            "\(amount)",
            formatter.string(from: transactionDate),
            comment ?? "",
            formatter.string(from: createdAt),
            formatter.string(from: updatedAt)
        ]
        
        return fields.joined(separator: ",")
    }
}

