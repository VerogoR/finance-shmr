import Foundation

final class TransactionsFileCache {

    private(set) var transactions: [Transaction] = []

    func add(_ transaction: Transaction) {
        guard !transactions.contains(where: { $0.id == transaction.id }) else { return }
        transactions.append(transaction)
    }

    func remove(id: String) {
        transactions.removeAll { $0.id == id }
    }

    func save(to fileURL: URL) throws {
        let jsonArray = transactions.map { $0.jsonObject }

        let data = try JSONSerialization.data(withJSONObject: jsonArray, options: [.prettyPrinted])

        try data.write(to: fileURL, options: [.atomic])
    }

    func load(from fileURL: URL) throws {
        let data = try Data(contentsOf: fileURL)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

        guard let jsonArray = jsonObject as? [Any] else {
            throw NSError(domain: "Invalid JSON structure", code: 0, userInfo: nil)
        }

        transactions = jsonArray.compactMap { Transaction.parse(jsonObject: $0) }
    }
}

