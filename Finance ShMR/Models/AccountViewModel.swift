import Foundation
import Combine
import SwiftUI
import UIKit
import Charts

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

    @Published var chartPeriod: ChartPeriod = .day
    @Published private var dayPoints:   [BalancePoint] = []
    @Published private var monthPoints: [BalancePoint] = []
    
    var points: [BalancePoint] { chartPeriod == .day ? dayPoints : monthPoints }
     
    private let ts = TransactionsService.shared
    private let cs = CategoriesService()
    private let bas = BankAccountsService.shared
    
    private var incomeCategories: Set<Int> = []
    
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
            let acc = try await bas.getBankAccount()
            account = acc
            balanceInput = Self.formatBalance(acc.balance, currency: acc.currency)
            selectedCurrency = Currency(rawValue: account!.currency) ?? .rub
        } catch {
            throw error
        }
    }

    func updateDayMonthPoints() async throws {
        do {
            try await loadCategories()
            async let dayLoad = loadChartData(period: .day)
            async let monthLoad = loadChartData(period: .month)
            let (day, month) = try await (dayLoad, monthLoad)
            dayPoints = day
            monthPoints = month
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
            let account = try await bas.updateBankAccount(
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

    private func loadCategories() async throws {
        let cats = try await cs.categories()
        incomeCategories = Set(
            cats.filter { $0.isIncome }.map(\.id)
        )
    }

    func loadChartData(period: ChartPeriod) async throws -> [BalancePoint] {
        let end = Calendar.current.startOfDay(for: .now)
        let (start, count, component): (Date, Int, Calendar.Component) = {
            switch period {
            case .day:
                let start = Calendar.current.date(byAdding: .day, value: -29, to: end)!
                return (start, 30, .day)
            case .month:
                let monthStart = Calendar.current.date(
                    from: Calendar.current.dateComponents([.year, .month], from: end)
                )!
                let start = Calendar.current.date(byAdding: .month, value: -24, to: monthStart)!
                return (start, 25, .month)
            }
        }()
        
        let transactions = try await ts.transactions(for: start...Date())
        let grouped = Dictionary(grouping: transactions) { Calendar.current.dateInterval(of: component, for: $0.transactionDate)!.start }
        
        return (0..<count).map { offset in
            let date = Calendar.current.date(byAdding: component, value: offset, to: start)!
            let sum = grouped[date]?.reduce(into: Decimal.zero) { acc, tx in
                let signed = incomeCategories.contains(tx.category.id) ? tx.amount : -tx.amount
                acc += signed
            } ?? 0
            return BalancePoint(date: date, amount: sum)
        }
    }
    
}
