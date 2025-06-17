import Foundation

struct Transaction: Identifiable {
    let id: String
    let accountId: String
    let categoryId: String
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
    let createdAt: Date
    var updatedAt: Date
}
