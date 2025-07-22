import Foundation

extension Transaction {
    
    private static let dateFormatter: ISO8601DateFormatter = {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return formatter
        }()
    
    static func parse(jsonObject: Any) -> Transaction? {
        guard
            let dict = jsonObject as? [String: Any],
            let id = dict["id"] as? Int,
            let account = dict["account"] as? AccountBrief,
            let category = dict["category"] as? Category,
            let amountString = dict["amount"] as? String,
            let amount = Decimal(string: amountString),
            let transactionDateString = dict["transactionDate"] as? String,
            let createdAtString = dict["createdAt"] as? String,
            let updatedAtString = dict["updatedAt"] as? String,
            let transactionDate = dateFormatter.date(from: transactionDateString),
            let createdAt = dateFormatter.date(from: createdAtString),
            let updatedAt = dateFormatter.date(from: updatedAtString)
        else {
            return nil
        }

        let comment = dict["comment"] as? String

        return Transaction(
            id: id,
            account: account,
            category: category,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    var jsonObject: Any {
        var dict: [String: Any] = [
            "id": id,
            "account": account,
            "category": category,
            "amount": "\(amount)",
            "transactionDate": Self.dateFormatter.string(from: transactionDate),
            "createdAt": Self.dateFormatter.string(from: createdAt),
            "updatedAt": Self.dateFormatter.string(from: updatedAt)
        ]
        if let comment = comment {
            dict["comment"] = comment
        }
        return dict
    }
}

