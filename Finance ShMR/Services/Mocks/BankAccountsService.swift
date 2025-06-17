import Foundation

final class BankAccountsService {
    private var mockAccount = BankAccount(
        id: "1",
        userId: "1",
        name: "Основной счёт",
        balance: Decimal(string: "1000.00")!,
        currency: "RUB",
        createdAt: ISO8601DateFormatter().date(from: "2025-06-11T18:08:59.754Z")!,
        updatedAt: ISO8601DateFormatter().date(from: "2025-06-11T18:08:59.754Z")!
    )
    
    func getBankAccount() async throws -> BankAccount {
        return mockAccount
    }
    
    func updateBankAccount(balance: Decimal) async throws -> BankAccount {
        mockAccount = BankAccount(
            id: mockAccount.id,
            userId: mockAccount.userId,
            name: mockAccount.name,
            balance: balance,
            currency: mockAccount.currency,
            createdAt: mockAccount.createdAt,
            updatedAt: Date()
        )
        return mockAccount
    }
}

