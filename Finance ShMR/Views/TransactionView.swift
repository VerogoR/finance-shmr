import SwiftUI

final class TransactionViewModel: ObservableObject {
    private var categoriesService = CategoriesService()
    private var transactionsService = TransactionsService.shared
    private var accountServiece = BankAccountsService.shared
    
    @Published var categories = [Category]()
    @Published var transactions: [Transaction] = []
    @Published var balanceInput: String = ""
    
    @Published var selectedCategoryName: String?
    @Published var selectedDate = Date()
    @Published var selectedTime = Date()
    @Published var commentInput: String = ""
    @Published var combinedDateTime = Date()
    
    private var account: BankAccount?
    private var currency: String = ""
    
    var balance: String {
        guard let account = account else { return "" }
        return String(account.balance.formatted(.currency(code: account.currency)))
    }
    
    @MainActor
    func fetchCategories() async {
        do {
            categories = try await categoriesService.categories()
            account = try await accountServiece.getBankAccount()
            currency = account?.currency ?? ""
            transactions = try await transactionsService.transactions(for: Calendar.current.date(byAdding: .month, value: -1, to: Date())!...Date())
        } catch {
            print("Ошибка при загрузке данных: \(error)")
        }
    }
    
    static func formatBalance(_ balance: Decimal, currency: String) -> String {
        return String(balance.formatted(.currency(code: currency)))
    }
    
    func parseBalanceInput(_ input: String) -> Decimal? {
        let cleanedInput = input
            .filter { !$0.isLetter }
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
    
    @MainActor
    func saveChanges(for transactionArg: Transaction) async {
        guard let newBalance = parseBalanceInput(balanceInput) else {
            print("Неверный формат баланса: \(balanceInput)")
            return
        }
        guard let selectedCategoryName, selectedCategoryName != "-" else {
            print("Категория не выбрана")
            return
        }
        guard var transaction = transactions.first(where: { $0.id == transactionArg.id }) else {
            print("Транзакция не найдена")
            return
        }
        do {
            let diff = (newBalance - transaction.amount) * (categories.first(where: { $0.name == selectedCategoryName })!.isIncome ? -1 : 1)
            balanceInput = Self.formatBalance(account!.balance - diff, currency: account!.currency)

            transaction.amount = newBalance
            transaction.category = categories.first(where: { $0.name == selectedCategoryName })!
            transaction.comment = commentInput
            transaction.updatedAt = Date()
            transaction.transactionDate = combinedDateTime
            
            try await transactionsService.updateTransaction(transaction)
        } catch {
            print("Ошибка сохранения: \(error)")
        }
    }
    
    @MainActor
    func createTransaction() async {
        guard var newBalance = parseBalanceInput(balanceInput) else {
            print("Неверный формат баланса: \(balanceInput)")
            return
        }
        guard let selectedCategoryName, selectedCategoryName != "-" else {
            print("Категория не выбрана")
            return
        }
        guard account != nil else {
            print("Аккаунт не найден")
            return
        }

        do {
            if categories.first(where: { $0.name == selectedCategoryName })?.isIncome ?? false {
                newBalance *= -1
            }
            balanceInput = Self.formatBalance(abs(newBalance), currency: account!.currency)

            let newTransaction = Transaction(
                id: (transactions.last?.id ?? 0) + 1,
                account: AccountBrief(account: account!),
                category: categories.first(where: { $0.name == selectedCategoryName })!,
                amount: abs(newBalance),
                transactionDate: combinedDateTime,
                comment: commentInput,
                createdAt: Date(),
                updatedAt: Date()
            )
            try await transactionsService.createTransaction(newTransaction)
        } catch {
            print("Ошибка создания транзакции: \(error)")
        }
    }
    
    func updateCombinedDateTime() {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
        combinedDateTime = calendar.date(bySettingHour: timeComponents.hour ?? 0,
                                         minute: timeComponents.minute ?? 0,
                                         second: 0,
                                         of: selectedDate) ?? Date()
        selectedDate = combinedDateTime
        selectedTime = combinedDateTime
    }
    
    @MainActor
    func deleteTransaction(_ transactionArg: Transaction) async {
        do {
            try await transactionsService.deleteTransaction(id: transactionArg.id)
        } catch {
            print("Ошибка при удалении транзакции: \(error)")
        }
    }
}

struct TransactionView: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var vm = TransactionViewModel()
    
    var direction: Direction
    var transaction: Transaction?
    
    @State private var showValidationAlert = false
    @State private var validationMessage = ""

    init(direction: Direction, _ transaction: Transaction?) {
        self.direction = direction
        self.transaction = transaction
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Статья", selection: $vm.selectedCategoryName) {
                        Text("-").tag(nil as String?)
                        ForEach(vm.categories.filter { $0.direction == direction }) { category in
                            Text(category.name).tag(category.name as String?)
                        }
                    }
                    HStack {
                        Text("Сумма")
                        TextField("", text: $vm.balanceInput)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.gray)
                    }
                    DatePicker("Дата", selection: $vm.selectedDate, in: ...Date(), displayedComponents: .date)
                        .onChange(of: vm.selectedDate) { vm.updateCombinedDateTime() }
                    DatePicker("Время", selection: $vm.selectedTime, in: ...Date(), displayedComponents: .hourAndMinute)
                        .onChange(of: vm.selectedTime) { vm.updateCombinedDateTime() }
                    TextField("Комментарий", text: $vm.commentInput)
//                    if vm.commentInput.isEmpty {
//                        ZStack {
//                            HStack {
//                                Text("Комментарий").foregroundColor(.gray)
//                                Spacer()
//                            }
//                            TextField("", text: $vm.commentInput)
//                        }
//                    } else {
//                        TextField("", text: $vm.commentInput)
//                    }
                }
                if transaction != nil {
                    Section {
                        Button(role: .destructive) {
                            Task {
                                await vm.deleteTransaction(transaction!)
                                dismiss()
                            }
                        } label: {
                            Text("Удалить \(direction == .income ? "доход" : "расход")")
                        }
                    }
                }
            }
            .task {
                await vm.fetchCategories()
                if let transaction = transaction {
                    vm.selectedDate = transaction.transactionDate
                    vm.selectedTime = transaction.transactionDate
                    vm.selectedCategoryName = transaction.category.name
                    vm.commentInput = transaction.comment ?? ""
                    vm.balanceInput = TransactionViewModel.formatBalance(transaction.amount, currency: transaction.account.currency)
                    vm.updateCombinedDateTime()
                }
            }
            .alert("Ошибка", isPresented: $showValidationAlert, actions: {
                Button("OK", role: .cancel) {}
            }, message: {
                Text(validationMessage)
            })
            .navigationTitle(direction == .income ? "Мои доходы" : "Мои расходы")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(.indigo)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(transaction == nil ? "Создать" : "Сохранить") {
                        if validateFields() {
                            Task {
                                if let existing = transaction {
                                    await vm.saveChanges(for: existing)
                                } else {
                                    await vm.createTransaction()
                                }
                                dismiss()
                            }
                        } else {
                            showValidationAlert = true
                        }
                    }
                    .foregroundStyle(Color.indigo)
                }
            }
        }
    }
    
    private func validateFields() -> Bool {
        if vm.selectedCategoryName == nil || vm.selectedCategoryName == "-" {
            validationMessage = "Пожалуйста, выберите категорию"
            return false
        }
        if vm.balanceInput.trimmingCharacters(in: .whitespaces).isEmpty {
            validationMessage = "Введите сумму операции"
            return false
        }
        if vm.parseBalanceInput(vm.balanceInput) == nil {
            validationMessage = "Некорректно указана сумма операции"
            return false
        }
//        if vm.combinedDateTime > Date() {
//            validationMessage = "Дата не может быть в будущем"
//            return false
//        }
        return true
    }
}

#Preview("create income") {
    TransactionView(direction: .income, nil)
}

#Preview("edit outcome") {
    TransactionView(
        direction: .outcome,
        Transaction(
            id: 52,
            account: AccountBrief(id: 1, name: "Bank Account", balance: 323, currency: "EUR"),
            category: Category(id: 5, name: "Coffee", emoji: "☕", isIncome: false),
            amount: 100,
            transactionDate: Date(),
            comment: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    )
}
