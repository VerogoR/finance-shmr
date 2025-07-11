import SwiftUI

enum TransactionViewType {
    case create
    case edit
}

final class TransactionViewModel: ObservableObject {
    private var categoriesService = CategoriesService()
    private var transactionsService = TransactionsService()
    private var accountServiece = BankAccountsService()
    
    @Published var categories = [Category]()
    @Published var transactions: [Transaction] = []
    @Published var balanceInput: String = ""
    
    private var account: BankAccount?
    private var currency: String = ""
    
    var balance: String {
        get {
            guard account != nil else { return "" }
            return String(account!.balance.formatted(.currency(code: account!.currency)))
        }
        set {
            
        }
    }
    
    @MainActor
    func fetchCategories() async {
        categories = try! await categoriesService.categories()
        account = try! await accountServiece.getBankAccount()
        currency = account!.currency
    }
    
    static func formatBalance(_ balance: Decimal, currency: String) -> String {
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
    
    func saveChanges() async {
        guard let newBalance = parseBalanceInput(balanceInput) else {
            print("Неверный формат баланса: \(balanceInput)")
            return
        }
        do {
            let updated = try await accountServiece.updateBankAccount(balance: account!.balance + newBalance, currency: currency)
            account = updated
            balanceInput = Self.formatBalance(updated.balance, currency: account!.currency)
            balance = newBalance.formatted(.currency(code: account!.currency))
        } catch {
            print("Ошибка сохранения: \(error)")
        }
    }
    
    func deleteTransaction(_ transactionArg: Transaction) async {
        try! await transactionsService.deleteTransaction(id: transactionArg.id)
    }
}

struct TransactionView: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var vm = TransactionViewModel()
    
//    var transactionType: TransactionViewType
    var direction: Direction
    var transaction: Transaction?
    
    @State private var selectedCategoryName: String?
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var commentInput: String = ""
    @State private var combinedDateTime = Date()
    
    init(direction: Direction, _ transaction: Transaction?) {
        self.transaction = transaction
        self.direction = direction
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Статья", selection: $selectedCategoryName) {
                        Text("-").tag(nil as String?)
                        
                        ForEach(vm.categories.filter {$0.direction == direction} ) { category in
                            Text(category.name).tag(category.name)
                        }
                    }
                    HStack {
                        Text("Сумма")
                        TextField("balance input", text: $vm.balanceInput)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.gray)
                    }
                    DatePicker("Дата", selection: $selectedDate, displayedComponents: .date)
                        .colorMultiply(.accentColor)
                        .onChange(of: selectedDate) { updateCombinedDateTime() }
                    DatePicker("Время", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .colorMultiply(.accentColor)
                        .onChange(of: selectedTime) { updateCombinedDateTime() }
                    if commentInput == "" {
                        ZStack {
                            HStack {
                                Text("Комментарий")
                                    .foregroundStyle(Color.gray)
                                Spacer()
                            }
                            TextField("", text: $commentInput)
                        }
                    } else {
                        TextField("", text: $commentInput)
                    }
                }
                Section {
                    if transaction != nil {
                        Button {
                            Task {
                                await vm.deleteTransaction(transaction!)
                            }
                        } label: {
                            Text("Удалить \(direction == .income ? "доход" : "расход")")
                                .foregroundStyle(Color.red)
                        }
                    }
                }
            }
            .task {
                await vm.fetchCategories()
                
                if let transaction = transaction {
                    selectedDate = transaction.transactionDate
                    selectedTime = transaction.transactionDate
                    selectedCategoryName = transaction.category.name
                    commentInput = transaction.comment ?? ""
                    vm.balanceInput = TransactionViewModel.formatBalance(transaction.amount, currency: transaction.account.currency)
                }
            }
            .navigationTitle(direction == .income ? "Мои доходы" : "Мои расходы")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundStyle(Color.indigo)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(transaction == nil ? "Создать" : "Сохранить") {
                        Task{
                            await vm.saveChanges()
                            dismiss()
                        }
                    }
                    .foregroundStyle(Color.indigo)
                }
            }
        }
    }
    
    private func updateCombinedDateTime() {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
        combinedDateTime = calendar.date(bySettingHour: timeComponents.hour ?? 0,
                                       minute: timeComponents.minute ?? 0,
                                       second: 0,
                                       of: selectedDate) ?? Date()
    }
}

#Preview("create income") {
    TransactionView(direction: .income, nil)
}

#Preview("edit outcome") {
    TransactionView(direction: .outcome, Transaction(id: 52, account: AccountBrief(id: 1, name: "Bank Account", balance: 323, currency: "EUR"), category: Category(id: 5, name: "Coffee", emoji: "f", isIncome: false), amount: 100, transactionDate: Date(), comment: nil, createdAt: Date(), updatedAt: Date()))
}
