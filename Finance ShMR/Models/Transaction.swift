//
//  Transaction.swift
//  Finance ShMR
//
//  Created by Egor Herdziy on 11.06.25.
//

import Foundation

struct Transaction: Identifiable {
    let id: UUID
    let categoryId: UUID
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        categoryId: UUID,
        amount: Decimal,
        transactionDate: Date,
        comment: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.categoryId = categoryId
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
