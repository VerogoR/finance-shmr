import Foundation

struct UpdateRequest: Encodable {
    let name: String
    let balance: String
    let currency: String
    
    enum CodingKeys: String, CodingKey {
        case name, balance, currency
    }
}

final class BankAccountsService {
    
    static let shared = BankAccountsService()
    private init() {}
    
    private static let formatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
    
    func getBankAccount() async throws -> BankAccount {
        let client = NetworkClient(token: Secret.token)
        do {
            let accounts: [BankAccount] = try await client.request(
                path: "accounts",
                method: "GET"
            )
            return accounts.first!
        } catch {
//            print("Ошибка: \(error.localizedDescription)")
            throw error
        }
    }
    
    func updateBankAccount(withID id: Int, name: String, balance: Decimal, currency: String) async throws -> BankAccount {
        let client = NetworkClient(token: Secret.token)
        do {
            let account: BankAccount = try await client.request(
                path: "accounts/\(id)",
                method: "PUT",
                body: UpdateRequest(name: name, balance: balance.formatted().replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\u{00A0}", with: ""), currency: currency)
            )
            return account
        } catch {
//            print("Ошибка: \(error.localizedDescription)")
            throw error
        }
    }
}

