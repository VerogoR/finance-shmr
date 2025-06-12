//
//  BankAccount.swift
//  Finance ShMR
//
//  Created by Egor Herdziy on 11.06.25.
//

import Foundation

struct BankAccount: Identifiable {
    let id = UUID()
    let userId: UUID
    var name: String
    var balance: Decimal
    let currency: String
    let createdAt: Date = Date()
    var updatedAt: Date = Date()
}
