import Foundation

final class TransactionsService {
    private var transactions: [Transaction] = [
        Transaction(
            id: "t1",
            accountId: "ta1",
            categoryId: "c1i",
            amount: Decimal(string: "1500.00")!,
            transactionDate: ISO8601DateFormatter().date(from: "2025-06-13T08:49:59.025Z")!,
            comment: "Зарплата",
            createdAt: ISO8601DateFormatter().date(from: "2025-06-13T08:49:59.025Z")!,
            updatedAt: ISO8601DateFormatter().date(from: "2025-06-13T08:49:59.025Z")!
        ),
        Transaction(
            id: "t2",
            accountId: "ta1",
            categoryId: "c2o",
            amount: Decimal(string: "500.00")!,
            transactionDate: ISO8601DateFormatter().date(from: "2025-06-13T08:49:59.025Z")!,
            comment: "Покупка продуктов",
            createdAt: ISO8601DateFormatter().date(from: "2025-06-13T08:49:59.025Z")!,
            updatedAt: ISO8601DateFormatter().date(from: "2025-06-13T08:49:59.025Z")!
        )
    ]
    
    func transactions(for period: ClosedRange<Date>) async throws -> [Transaction] {
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
    
    func deleteTransaction(id: String) async throws {
        transactions.removeAll { $0.id == id }
    }
}

