import Foundation

final class TransactionsService {
    
    static let shared = TransactionsService()
    private init() {}
    
    private static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    var categoriesService = CategoriesService()
    var bankAccountsService = BankAccountsService()
    
    private var transactions: [Transaction] = []

    func transactions(for period: ClosedRange<Date>) async -> [Transaction] {
        let account = try! await bankAccountsService.getBankAccount()
        let categories = try! await categoriesService.categories()

        if transactions.isEmpty {
            transactions = [
                Transaction(
                    id: 1,
                    account: AccountBrief(account: account),
                    category: categories[0],
                    amount: Decimal(string: "1500.00")!,
                    transactionDate: Date(),
                    comment: "Зарплата",
                    createdAt: Date(),
                    updatedAt: Date()
                ),
                Transaction(
                    id: 2,
                    account: AccountBrief(account: account),
                    category: categories[1],
                    amount: Decimal(string: "500.00")!,
                    transactionDate: Date(),
                    comment: "Покупка продуктов",
                    createdAt: Date(),
                    updatedAt: Date()
                ),
                Transaction(
                    id: 64,
                    account: AccountBrief(account: account),
                    category: categories[2],
                    amount: Decimal(string: "250.00")!,
                    transactionDate: Date(),
                    comment: "На кофе",
                    createdAt: Date(),
                    updatedAt: Date()
                )
            ]
        }

        return transactions.filter { period.contains($0.transactionDate) }
    }

    func createTransaction(_ transaction: Transaction) async throws {
        guard !transactions.contains(where: { $0.id == transaction.id }) else {
            throw NSError(domain: "Duplicate transaction", code: 1)
        }
        transactions.append(transaction)
    }

    func updateTransaction(_ transaction: Transaction) async throws {
        guard let index = transactions.firstIndex(where: { $0.id == transaction.id }) else {
            throw NSError(domain: "Transaction not found", code: 2)
        }
        transactions[index] = transaction
    }

    func deleteTransaction(id: Int) async throws {
        transactions.removeAll { $0.id == id }
    }
}
