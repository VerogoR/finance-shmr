import Foundation

struct AccountBrief: Identifiable, Codable {
    let id: Int
    let name: String
    let balance: Decimal
    let currency: String
    
    init(account: BankAccount) {
        self.id = account.id
        self.name = account.name
        self.balance = account.balance
        self.currency = account.currency
    }
    
    init(id: Int, name: String, balance: Decimal, currency: String) {
        self.id = id
        self.name = name
        self.balance = balance
        self.currency = currency
    }
}
