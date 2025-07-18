import Foundation

struct StatItemResponse: Decodable {
    let categoryId: Int
    let categoryName: String
    let emoji: String
    let amount: String
}

struct AccountResponse: Decodable {
    let id: Int
    let name: String
    let balance: String
    let currency: String
    let incomeStats: [StatItemResponse]
    let expenseStats: [StatItemResponse]
    let createdAt: String
    let updatedAt: String
}

struct StatItem {
    let categoryId: Int
    let categoryName: String
    let emoji: String
    let amount: Decimal
}

struct BankAccount: Decodable, Identifiable {
    let id: Int
    let userId: Int
    var name: String
    var balance: Decimal
    var currency: String
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, userId, name, balance, currency, createdAt, updatedAt
    }
    
    init(id: Int, userId: Int, name: String, balance: Decimal, currency: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.userId = userId
        self.name = name
        self.balance = balance
        self.currency = currency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decode(Int.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        currency = try container.decode(String.self, forKey: .currency)
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        guard let createdDate = dateFormatter.date(from: createdAtString) else {
            throw DecodingError.dataCorruptedError(forKey: .createdAt, in: container, debugDescription: "Invalid date format")
        }
        createdAt = createdDate
        
        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
        guard let updatedDate = dateFormatter.date(from: updatedAtString) else {
            throw DecodingError.dataCorruptedError(forKey: .updatedAt, in: container, debugDescription: "Invalid date format")
        }
        updatedAt = updatedDate
        
        let balanceString = try container.decode(String.self, forKey: .balance)
        guard let balanceDecimal = Decimal(string: balanceString) else {
            throw DecodingError.dataCorruptedError(forKey: .balance, in: container, debugDescription: "Invalid decimal format")
        }
        balance = balanceDecimal
    }
    
    init(from response: AccountResponse) throws {
        self.id = response.id
        self.name = response.name
        
        guard let balanceDecimal = Decimal(string: response.balance) else {
            throw NSError(domain: "Account", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid balance format"])
        }
        self.balance = balanceDecimal
        
        self.currency = response.currency
        
        func convertStats(_ stats: [StatItemResponse]) throws -> [StatItem] {
            try stats.map { stat in
                guard let amountDecimal = Decimal(string: stat.amount) else {
                    throw NSError(domain: "Account", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid amount format"])
                }
                return StatItem(
                    categoryId: stat.categoryId,
                    categoryName: stat.categoryName,
                    emoji: stat.emoji,
                    amount: amountDecimal
                )
            }
        }
        
        guard let createdDate = BankAccount.isoFormatter.date(from: response.createdAt),
              let updatedDate = BankAccount.isoFormatter.date(from: response.updatedAt) else {
            throw NSError(domain: "Account", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid date format"])
        }
        self.createdAt = createdDate
        self.updatedAt = updatedDate
        
        self.userId = 1
    }
    
    private static let isoFormatter: ISO8601DateFormatter = {
            let f = ISO8601DateFormatter()
            f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return f
        }()

}
