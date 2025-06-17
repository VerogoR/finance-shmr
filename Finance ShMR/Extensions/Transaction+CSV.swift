import Foundation

extension Transaction {
    
    static func parse(csvLine: String) -> Transaction? {
        let components = csvLine.components(separatedBy: ",")
        guard components.count == 8 else {
            return nil
        }
        
        let id = components[0]
        let accountId = components[1]
        let categoryId = components[2]
        let amountString = components[3]
        let transactionDateString = components[4]
        let commentString = components[5]
        let createdAtString = components[6]
        let updatedAtString = components[7]
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard
            let amount = Decimal(string: amountString),
            let transactionDate = formatter.date(from: transactionDateString),
            let createdAt = formatter.date(from: createdAtString),
            let updatedAt = formatter.date(from: updatedAtString)
        else {
            return nil
        }
        
        return Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: transactionDate,
            comment: commentString.isEmpty ? nil : commentString,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    var csvLine: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let fields: [String] = [
            id,
            accountId,
            categoryId,
            "\(amount)",
            formatter.string(from: transactionDate),
            comment ?? "",
            formatter.string(from: createdAt),
            formatter.string(from: updatedAt)
        ]
        
        return fields.joined(separator: ",")
    }
}

