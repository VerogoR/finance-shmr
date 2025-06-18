import Foundation

extension Transaction {
    static func parse(from csv: String) -> [Transaction]? {
        let isoFormatter = ISO8601DateFormatter()
        
        let rows = csv.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard rows.count > 1 else { return nil }
        
        var transactions: [Transaction] = []
        
        for row in rows.dropFirst() {
            let columns = row.components(separatedBy: ",")
            guard columns.count == 14 else { continue }
            
            guard let id = Int(columns[0]),
                  let accountId = Int(columns[1]),
                  let balance = Decimal(string: columns[3]),
                  let categoryId = Int(columns[5]),
                  let emoji = columns[7].first,
                  let isIncome = Bool(columns[8]),
                  let amount = Decimal(string: columns[9]),
                  let transactionDate = isoFormatter.date(from: columns[10]),
                  let comment = columns[11].isEmpty ? nil : columns[11],
                  let createdAt = isoFormatter.date(from: columns[12]),
                  let updatedAt = isoFormatter.date(from: columns[13])
            else {
                return nil
            }
            
            let accountName = columns[2]
            let currency = columns[4]
            let categoryName = columns[6]
            
            
            let account = AccountBrief(
                id: accountId,
                name: accountName,
                balance: balance,
                currency: currency
            )
            
            let category = Category(
                id: categoryId,
                name: categoryName,
                emoji: emoji,
                isIncome: isIncome
            )
            
            let transaction = Transaction(
                id: id,
                account: account,
                category: category,
                amount: amount,
                transactionDate: transactionDate,
                comment: comment,
                createdAt: createdAt,
                updatedAt: updatedAt
            )
            transactions.append(transaction)
        }
        return transactions
    }
    
    
    var csvLine: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let fields: [String] = [
            "\(id)",
            "\(account.id)",
            account.name,
            "\(account.balance)",
            account.currency,
            "\(category.id)",
            category.name,
            "\(category.emoji)",
            "\(category.isIncome)",
            "\(amount)",
            formatter.string(from: transactionDate),
            comment ?? "",
            formatter.string(from: createdAt),
            formatter.string(from: updatedAt)
        ]
        
        return fields.joined(separator: ",")
    }
}
