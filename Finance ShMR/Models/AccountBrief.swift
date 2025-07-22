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
    
    enum CodingKeys: String, CodingKey {
        case id, name, balance, currency
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        let balanceString = try container.decode(String.self, forKey: .balance)
        guard let balanceDecimal = Decimal(string: balanceString) else {
            throw DecodingError.dataCorruptedError(forKey: .balance, in: container, debugDescription: "Invalid decimal format")
        }
        balance = balanceDecimal
        
        currency = try container.decode(String.self, forKey: .currency)
    }
}
