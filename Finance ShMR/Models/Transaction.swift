import Foundation

struct Transaction: Identifiable {
    let id: Int
    let account: AccountBrief
    let category: Category
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
    let createdAt: Date
    var updatedAt: Date
}
