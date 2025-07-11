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
    
    func transactions(for period: ClosedRange<Date>) async -> [Transaction] {
        
        let account = try! await bankAccountsService.getBankAccount()
        let categories: [Category] = try! await categoriesService.categories()
        
        transactions = [
            Transaction(
                id: 1,
                account: AccountBrief(account: account),
                category: categories[0],
                amount: Decimal(string: "1500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 2,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 3,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "2500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 4,
                account: AccountBrief(account: account),
                category: categories[2],
                amount: Decimal(string: "250.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 5,
                account: AccountBrief(account: account),
                category: categories[0],
                amount: Decimal(string: "1500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Зарплата",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 6,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Покупка продуктов",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 7,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "2500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Аренда квартиры",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 8,
                account: AccountBrief(account: account),
                category: categories[2],
                amount: Decimal(string: "250.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "На кофе",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 9,
                account: AccountBrief(account: account),
                category: categories[0],
                amount: Decimal(string: "1500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Зарплата",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 10,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Покупка продуктов",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 11,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "2500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Аренда квартиры",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 12,
                account: AccountBrief(account: account),
                category: categories[2],
                amount: Decimal(string: "250.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "На кофе",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 13,
                account: AccountBrief(account: account),
                category: categories[0],
                amount: Decimal(string: "1500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Зарплата",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 14,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Покупка продуктов",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 15,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "2500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Аренда квартиры",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 16,
                account: AccountBrief(account: account),
                category: categories[2],
                amount: Decimal(string: "250.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "На кофе",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 17,
                account: AccountBrief(account: account),
                category: categories[0],
                amount: Decimal(string: "1500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Зарплата",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 18,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Покупка продуктов",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 19,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "2500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Аренда квартиры",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 20,
                account: AccountBrief(account: account),
                category: categories[2],
                amount: Decimal(string: "250.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "На кофе",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 21,
                account: AccountBrief(account: account),
                category: categories[0],
                amount: Decimal(string: "1500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Зарплата",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 22,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Покупка продуктов",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 23,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "2500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Аренда квартиры",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 24,
                account: AccountBrief(account: account),
                category: categories[2],
                amount: Decimal(string: "250.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "На кофе",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 25,
                account: AccountBrief(account: account),
                category: categories[0],
                amount: Decimal(string: "1500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Зарплата",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 26,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Покупка продуктов",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 27,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "2500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Аренда квартиры",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 28,
                account: AccountBrief(account: account),
                category: categories[2],
                amount: Decimal(string: "250.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "На кофе",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 29,
                account: AccountBrief(account: account),
                category: categories[0],
                amount: Decimal(string: "1500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Зарплата",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 30,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Покупка продуктов",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 31,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "2500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Аренда квартиры",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 32,
                account: AccountBrief(account: account),
                category: categories[2],
                amount: Decimal(string: "250.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "На кофе",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 33,
                account: AccountBrief(account: account),
                category: categories[0],
                amount: Decimal(string: "1500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Зарплата",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 34,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Покупка продуктов",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 35,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "2500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Аренда квартиры",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 36,
                account: AccountBrief(account: account),
                category: categories[2],
                amount: Decimal(string: "250.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "На кофе",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 37,
                account: AccountBrief(account: account),
                category: categories[0],
                amount: Decimal(string: "1500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Зарплата",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 38,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Покупка продуктов",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 39,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "2500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Аренда квартиры",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 40,
                account: AccountBrief(account: account),
                category: categories[2],
                amount: Decimal(string: "250.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "На кофе",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 41,
                account: AccountBrief(account: account),
                category: categories[0],
                amount: Decimal(string: "1500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Зарплата",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 42,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Покупка продуктов",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 43,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "2500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Аренда квартиры",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 44,
                account: AccountBrief(account: account),
                category: categories[2],
                amount: Decimal(string: "250.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "На кофе",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 45,
                account: AccountBrief(account: account),
                category: categories[0],
                amount: Decimal(string: "1500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Зарплата",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 46,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Покупка продуктов",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 47,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "2500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Аренда квартиры",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 48,
                account: AccountBrief(account: account),
                category: categories[2],
                amount: Decimal(string: "250.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "На кофе",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 49,
                account: AccountBrief(account: account),
                category: categories[0],
                amount: Decimal(string: "1500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Зарплата",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 50,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Покупка продуктов",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 51,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "2500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Аренда квартиры",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 52,
                account: AccountBrief(account: account),
                category: categories[2],
                amount: Decimal(string: "250.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "На кофе",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 53,
                account: AccountBrief(account: account),
                category: categories[0],
                amount: Decimal(string: "1500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Зарплата",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 54,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Покупка продуктов",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 55,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "2500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Аренда квартиры",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 56,
                account: AccountBrief(account: account),
                category: categories[2],
                amount: Decimal(string: "250.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "На кофе",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 57,
                account: AccountBrief(account: account),
                category: categories[0],
                amount: Decimal(string: "1500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Зарплата",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 58,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Покупка продуктов",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 59,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "2500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Аренда квартиры",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 60,
                account: AccountBrief(account: account),
                category: categories[2],
                amount: Decimal(string: "250.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "На кофе",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 61,
                account: AccountBrief(account: account),
                category: categories[0],
                amount: Decimal(string: "1500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Зарплата",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 62,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Покупка продуктов",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 63,
                account: AccountBrief(account: account),
                category: categories[1],
                amount: Decimal(string: "2500.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "Аренда квартиры",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            ),
            Transaction(
                id: 64,
                account: AccountBrief(account: account),
                category: categories[2],
                amount: Decimal(string: "250.00")!,
                transactionDate: Self.dateFormatter.date(from: Self.dateFormatter.string(from: Date()))!,
                comment: "На кофе",
                createdAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!,
                updatedAt: Self.dateFormatter.date(from: "2025-06-13T08:49:59.025Z")!
            )
        ]
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

extension Date {
    func convertedToLocalTime() -> Date {
        let timeZoneOffset = TimeInterval(TimeZone.current.secondsFromGMT(for: self))
        return self.addingTimeInterval(timeZoneOffset)
    }
}

