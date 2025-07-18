import Foundation

struct TransactionRequest: Encodable {
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: String
    let comment: String?
    
    init(from transaction: Transaction) {
        let formatterWithMS = ISO8601DateFormatter()
        formatterWithMS.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        self.accountId = transaction.account.id
        self.categoryId = transaction.category.id
        self.amount = transaction.amount.formatted().replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\u{00A0}", with: "")
        self.transactionDate = formatterWithMS.string(from: Calendar.current.date(byAdding: .hour, value: 3, to: transaction.transactionDate)!)
        self.comment = transaction.comment
    }
    
    enum CodingKeys: CodingKey {
        case accountId
        case categoryId
        case amount
        case transactionDate
        case comment
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.accountId, forKey: .accountId)
        try container.encode(self.categoryId, forKey: .categoryId)
        try container.encode(self.amount, forKey: .amount)
        try container.encode(self.transactionDate, forKey: .transactionDate)
        try container.encodeIfPresent(self.comment, forKey: .comment)
    }
}

struct TransactionResponse: Decodable {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: String
    let comment: String?
    let createdAt: String
    let updatedAt: String
}

final class TransactionsService {
    
    static let shared = TransactionsService()
    private init() {}
    
    private static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    var categoriesService = CategoriesService()
    var bankAccountsService = BankAccountsService.shared
    
    private var transactions: [Transaction] = []
    
    func transactions(for period: ClosedRange<Date>) async throws -> [Transaction] {
        let account = try! await bankAccountsService.getBankAccount()
        let client = NetworkClient(token: Secret.token)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startDate = formatter.string(from: period.lowerBound)
        let endDate = formatter.string(from: period.upperBound)
        do {
            let transactions: [Transaction] = try await client.request(
                path: "transactions/account/\(account.id)/period",
                method: "GET",
                queryItems: [
                    URLQueryItem(name: "startDate", value: startDate),
                    URLQueryItem(name: "endDate", value: endDate)
                ]
            )
            self.transactions = transactions
            return transactions
        } catch {
            print("Ошибка: \(error.localizedDescription)")
            throw error
        }
    }

    func createTransaction(_ transaction: Transaction) async throws {
        guard !transactions.contains(where: { $0.id == transaction.id }) else {
            throw NSError(domain: "Duplicate transaction", code: 1)
        }
        let client = NetworkClient(token: Secret.token)
        do {
            let transaction: TransactionResponse = try await client.request(
                path: "transactions",
                method: "POST",
                body: TransactionRequest(from: transaction)
            )
            print("Создана транзакция: \(transaction)")
//            transactions.append(transaction)
        } catch {
            print("Ошибка: \(error.localizedDescription)")
            throw error
        }
    }

    func updateTransaction(_ transaction: Transaction) async throws {
        guard let index = transactions.firstIndex(where: { $0.id == transaction.id }) else {
            throw NSError(domain: "Transaction not found", code: 2)
        }
        let client = NetworkClient(token: Secret.token)
        do {
            let transaction: Transaction = try await client.request(
                path: "transactions/\(transaction.id)",
                method: "PUT",
                body: TransactionRequest(from: transaction)
            )
            print("Обновлена транзакция: \(transaction)")
            transactions[index] = transaction
        } catch {
            print("Ошибка: \(error.localizedDescription)")
            throw error
        }
    }

    func deleteTransaction(id: Int) async throws {
        transactions.removeAll { $0.id == id }
        let client = NetworkClient(token: Secret.token)
        do {
            try await client.request(path: "transactions/\(id)", method: "DELETE")
        }
    }
}
