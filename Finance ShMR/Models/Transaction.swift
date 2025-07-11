import Foundation

struct Transaction: Identifiable {
    let id: Int
    let account: AccountBrief
    var category: Category
    var amount: Decimal
    var transactionDate: Date
    var comment: String?
    let createdAt: Date
    var updatedAt: Date
}
