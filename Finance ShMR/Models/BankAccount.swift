//
//  BankAccount.swift
//  Finance ShMR
//
//  Created by Egor Herdziy on 11.06.25.
//

import Foundation

struct BankAccount: Identifiable {
    let id: String
    let userId: String
    var name: String
    var balance: Decimal
    let currency: String
    let createdAt: Date
    var updatedAt: Date
}
