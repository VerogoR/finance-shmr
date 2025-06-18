import Testing
import Foundation

@testable import Finance_ShMR

struct TransactionJSONTests {
    
    var categoriesService = CategoriesService()
    var bankAccountsService = BankAccountsService()
    
    let account: BankAccount
    let categories: [Finance_ShMR.Category]
    
    init() async {
        
        account = try! await bankAccountsService.getBankAccount()
        categories = try! await categoriesService.categories()
        
    }
    
    @Test
    func testParseValidJSONObject() {
        let account = AccountBrief(account: account)
        let category = categories[0]
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let json: [String: Any] = [
            "id": 1,
            "account": account,
            "category": category,
            "amount": "1000.00",
            "transactionDate": dateFormatter.string(from: Date(timeIntervalSince1970: 1718650000)),
            "createdAt": dateFormatter.string(from: Date(timeIntervalSince1970: 1718650100)),
            "updatedAt": dateFormatter.string(from: Date(timeIntervalSince1970: 1718650200)),
            "comment": "Зарплата"
        ]
        
        let transaction = Transaction.parse(jsonObject: json)
        
        #expect(transaction != nil)
        #expect(transaction?.amount == Decimal(string: "1000.00"))
        #expect(transaction?.comment == "Зарплата")
        #expect(transaction?.account.id == account.id)
        #expect(transaction?.category.id == category.id)
    }

    @Test
    func testParseInvalidJSONObject() {
        let json: [String: Any] = [
            "id": "notAnInt"
        ]
        let transaction = Transaction.parse(jsonObject: json)
        #expect(transaction == nil)
    }

    @Test
    func testJSONObjectMatchesTransaction() {
        let account = AccountBrief(account: account)
        let category = categories[1]
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let transaction = Transaction(
            id: 1,
            account: account,
            category: category,
            amount: Decimal(string: "750.50")!,
            transactionDate: Date(timeIntervalSince1970: 1718650000),
            comment: "Покупка продуктов",
            createdAt: Date(timeIntervalSince1970: 1718650100),
            updatedAt: Date(timeIntervalSince1970: 1718650200)
        )
        
        guard let json = transaction.jsonObject as? [String: Any] else {
            return
        }
        
        #expect(json["id"] as? Int == transaction.id)
        #expect(json["amount"] as? String == "750.5")
        #expect(json["comment"] as? String == "Покупка продуктов")
        
        guard let jsonAccount = json["account"] as? AccountBrief else {
            return
        }
        guard let jsonCategory = json["category"] as? Finance_ShMR.Category else {
            return
        }
        
        #expect(jsonAccount.id == account.id)
        #expect(jsonAccount.name == account.name)
        #expect(jsonAccount.currency == account.currency)
        
        #expect(jsonCategory.id == category.id)
        #expect(jsonCategory.name == category.name)
        #expect(jsonCategory.emoji == category.emoji)
        #expect(jsonCategory.isIncome == category.isIncome)
    }
}
