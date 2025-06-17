import Testing
import Foundation

@testable import Finance_ShMR

struct TransactionTests {
    
    @Test
    func testParseValidJsonObject() throws {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let transactionId = "tt1"
        let accountId = "ta1"
        let categoryId = "tc1"
        let now = Date()
        
        let jsonObject: [String: Any] = [
            "id": transactionId,
            "accountId": accountId,
            "categoryId": categoryId,
            "amount": "1234.56",
            "transactionDate": formatter.string(from: now),
            "comment": "Test transaction",
            "createdAt": formatter.string(from: now),
            "updatedAt": formatter.string(from: now)
        ]
        
        let transaction = Transaction.parse(jsonObject: jsonObject)
        
        #expect(transaction != nil)
        #expect(transaction?.id == transactionId)
        #expect(transaction?.categoryId == categoryId)
        #expect(transaction?.amount == Decimal(string: "1234.56"))
        #expect(transaction?.comment == "Test transaction")
        
        let lhs = transaction?.transactionDate.timeIntervalSince1970 ?? 0
        let rhs = now.timeIntervalSince1970
        let difference = abs(lhs - rhs)
        #expect(difference < 0.01)

        
    }
    
    @Test
    func testParseInvalidJsonObject() {
        let invalidJsonObject: [String: Any] = [
            "invalidKey": "invalidValue"
        ]
        
        let transaction = Transaction.parse(jsonObject: invalidJsonObject)
        
        #expect(transaction == nil)
    }
    
    @Test
    func testJsonObjectGeneration() throws {
        let transaction = Transaction(
            id: "tt2",
            accountId: "ta2",
            categoryId: "tc2",
            amount: Decimal(string: "789.00")!,
            transactionDate: Date(),
            comment: "Sample",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        guard let dict = transaction.jsonObject as? [String: Any] else {
                    #expect(Bool(false), "jsonObject is not a dictionary")
                    return
                }
        
        #expect(dict["id"] as? String == transaction.id)
        #expect(dict["accountId"] as? String == transaction.accountId)
        #expect(dict["categoryId"] as? String == transaction.categoryId)
        #expect(dict["amount"] as? String == "\(transaction.amount)")
        #expect(dict["comment"] as? String == transaction.comment)
        
        #expect(dict["transactionDate"] as? String != nil)
        #expect(dict["createdAt"] as? String != nil)
        #expect(dict["updatedAt"] as? String != nil)
    }
}

