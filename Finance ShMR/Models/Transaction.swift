import Foundation

struct Transaction: Identifiable, Decodable {
    let id: Int
    let account: AccountBrief
    var category: Category
    var amount: Decimal
    var transactionDate: Date
    var comment: String?
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, account, category, amount, transactionDate, comment, createdAt, updatedAt
    }
    
    init(id: Int, account: AccountBrief, category: Category, amount: Decimal, transactionDate: Date, comment: String?, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.account = account
        self.category = category
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        account = try container.decode(AccountBrief.self, forKey: .account)
        category = try container.decode(Category.self, forKey: .category)

        let amountString = try container.decode(String.self, forKey: .amount)
        guard let amountDecimal = Decimal(string: amountString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .amount,
                in: container,
                debugDescription: "Invalid decimal format"
            )
        }
        amount = amountDecimal

        transactionDate = try Self.decodeISODate(from: container, forKey: .transactionDate)
        createdAt = try Self.decodeISODate(from: container, forKey: .createdAt)
        updatedAt = try Self.decodeISODate(from: container, forKey: .updatedAt)

        comment = try container.decodeIfPresent(String.self, forKey: .comment)
    }

    private static func decodeISODate(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) throws -> Date {
        let dateString = try container.decode(String.self, forKey: key)
        let formatterWithMS = ISO8601DateFormatter()
        formatterWithMS.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let formatterWithoutMS = ISO8601DateFormatter()
        formatterWithoutMS.formatOptions = [.withInternetDateTime]

        if let date = formatterWithMS.date(from: dateString) ?? formatterWithoutMS.date(from: dateString) {
            return date
        }

        throw DecodingError.dataCorruptedError(
            forKey: key,
            in: container,
            debugDescription: "Invalid ISO8601 date format: \(dateString)"
        )
    }
}
