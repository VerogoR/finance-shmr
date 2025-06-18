import Foundation

final class TransactionsService {
    
    private static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    var categoriesService = CategoriesService()
    var bankAccountsService = BankAccountsService()
    
    private var transactions: [Transaction] = []
    
    let account: BankAccount
    let categories: [Category]
    
    init() async {
        
        account = try! await bankAccountsService.getBankAccount()
        categories = try! await categoriesService.categories()
        
        
        transactions = [
            Transaction(
                id: 1,
                account: AccountBrief(account: account),
                category: categories[0],
                amount: Decimal(string: "1500.00")!,
                transactionDate: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                comment: "Зарплата",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 2,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "500.00")!,
                transactionDate: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                comment: "Покупка продуктов",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            )
        ]
    }
    
    func transactions(for period: ClosedRange<Date>) async -> [Transaction] {
        return transactions.filter { period.contains($0.transactionDate.convertedToLocalTime()) }
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

extension Date {
    func convertedToLocalTime() -> Date {
        let timeZoneOffset = TimeInterval(TimeZone.current.secondsFromGMT(for: self))
        return self.addingTimeInterval(timeZoneOffset)
    }
}

