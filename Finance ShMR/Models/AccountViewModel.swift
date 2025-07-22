import Foundation
import Combine
import SwiftUI
import UIKit

enum Currency: String, CaseIterable, Identifiable {
    case rub = "RUB"
    case usd = "USD"
    case eur = "EUR"
    var id: String { rawValue }
}

@MainActor
class AccountViewModel: ObservableObject {
    @Published var account: BankAccount?
    @Published var balanceInput: String = ""
    @Published var isBalanceHidden = false
    @Published var selectedCurrency: Currency = .rub

    private let service = BankAccountsService.shared
    
    var balance: String {
        get {
            guard account != nil else { return "" }
            return String(account!.balance.formatted(.currency(code: account!.currency)))
        }
        set {
            
        }
    }
    
    var selectedCurrencySymbol: String {
        switch selectedCurrency {
        case .rub: return "₽"
        case .usd: return "$"
        case .eur: return "€"
        }
    }


    func fetchAccount() async throws {
        do {
            let acc = try await service.getBankAccount()
            account = acc
            balanceInput = Self.formatBalance(acc.balance, currency: acc.currency)
            selectedCurrency = Currency(rawValue: account!.currency) ?? .rub
        } catch {
            throw error
        }
    }

    func saveChanges() async throws {
        guard let newBalance = parseBalanceInput(balanceInput) else {
            print("Неверный формат баланса: \(balanceInput)")
            return
        }
        do {
            let account = try await service.updateBankAccount(
                withID: account!.id,
                name: " ",
                balance: newBalance,
                currency: selectedCurrency.rawValue
            )
            balanceInput = Self.formatBalance(account.balance, currency: account.currency)
            balance = newBalance.formatted(.currency(code: account.currency))
        } catch {
            throw error
        }
    }
    
    func saveCurrency() {
        account?.currency = selectedCurrency.rawValue
    }

    func toggleBalanceHidden() {
        withAnimation {
            isBalanceHidden.toggle()
        }
    }


    private static func formatBalance(_ balance: Decimal, currency: String) -> String {
        return String(balance.formatted(.currency(code: currency)))
    }
    
    private func parseBalanceInput(_ input: String) -> Decimal? {
        let cleanedInput = input
            .filter( { !$0.isLetter } )
            .replacingOccurrences(of: "\u{00A0}", with: "")
            .replacingOccurrences(of: "₽", with: "")    
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: "€", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.generatesDecimalNumbers = true

        return formatter.number(from: cleanedInput)?.decimalValue
    }


}
