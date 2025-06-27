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

    private let service = BankAccountsService()
    
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


    func fetchAccount() async {
        do {
            let acc = try await service.getBankAccount()
            account = acc
            balanceInput = Self.formatBalance(acc.balance, currency: acc.currency)
        } catch {
            print("Ошибка загрузки аккаунта: \(error)")
        }
    }

    func saveChanges() async {
        guard let newBalance = parseBalanceInput(balanceInput) else {
            print("Неверный формат баланса: \(balanceInput)")
            return
        }
        do {
            let updated = try await service.updateBankAccount(balance: newBalance, currency: selectedCurrency.rawValue)
            account = updated
            balanceInput = Self.formatBalance(updated.balance, currency: account!.currency)
            balance = newBalance.formatted(.currency(code: account!.currency))
        } catch {
            print("Ошибка сохранения: \(error)")
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
