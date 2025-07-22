import SwiftUI

struct TransactionsListView: View {
    
    private enum sortedBy {
        case date
        case amount
    }
    
    private struct AddButtonModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color.accentColor)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 4)
        }
    }
    
    @State private var currentSorting: sortedBy = .date
    
    @State private var todaysTransactions: [Transaction] = []
    @State private var transactionService = TransactionsService.shared
    
    @State private var isShowingEditView: Bool = false
    
    @State private var currentTransaction: Transaction?
    
    private var account: BankAccount?
    
    let direction: Direction
    private let calendar = Calendar.current
    
    init(direction: Direction) {
        self.direction = direction
    }
    
    var todayTransactionsValue: Decimal {
        let correctDirectionTransactions: [Transaction] = todaysTransactions.filter( { $0.category.direction == direction } )
        return correctDirectionTransactions.reduce(0) { result, transaction in
            result + transaction.amount
        }
    }
    
    private var summarySection: some View {
        Section {
            Picker("Сортировка", selection: $currentSorting){
                Text("Дата").tag(sortedBy.date)
                Text("Сумма").tag(sortedBy.amount)
            }
            .pickerStyle(.segmented)
            
            HStack {
                Text("Всего")
                Spacer()
                Text(String(todaysTransactions.isEmpty ? "0" : todayTransactionsValue.formatted(.currency(code: todaysTransactions.first!.account.currency))))
            }
        }
    }
    
    
    private var tabsSection: some View {
        Section(header: Text("Операции")) {
            ForEach(todaysTransactions.filter( { $0.category.direction == direction } ).sorted(by: currentSorting == .date ? { $0.transactionDate > $1.transactionDate } : { $0.amount > $1.amount })) { transaction in
                TransactionTab(transaction: transaction)
                    .onTapGesture {
                        currentTransaction = transaction
                        isShowingEditView = true
                    }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    summarySection
                    tabsSection
                }
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Button {
                            currentTransaction = nil
                            isShowingEditView = true
                        } label: {
                            Image(systemName: "plus")
                                .modifier(AddButtonModifier())
                        }
                        .padding(.bottom, 24)
                        .padding(.trailing, 24)
                    }
                }
            }
            .task {
                await loadTodaysTransactions()
            }
            .navigationTitle("\(direction == .income ? "Доходы" : "Расходы") сегодня")
            .toolbar {
                NavigationLink {
                    MyHistoryView(direction: direction)
                } label: {
                    Image(systemName: "clock")
                        .foregroundStyle(Color.indigo)
                }
            }
            .sheet(isPresented: $isShowingEditView, onDismiss: {
                Task {
                    await loadTodaysTransactions()
                }
            }){
                TransactionView(direction: direction, currentTransaction)
            }
        }
    }
    
    private func loadTodaysTransactions() async {
        let today = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: today)!
        todaysTransactions = try! await transactionService.transactions(for: today...endOfDay)
    }
}

struct TransactionTab: View {
    
    let transaction: Transaction
    
    init(transaction: Transaction) {
        self.transaction = transaction
    }
    
    var body: some View {
        HStack {
            transaction.category.direction == .outcome ? ZStack {
                Circle()
                    .frame(width: 35, height: 35)
                    .foregroundStyle(Color.accentColor)
                    .opacity(0.2)
                Text("\(transaction.category.emoji)")
            } : nil
            transaction.category.direction == .outcome ? Spacer()
                .frame(width: 15)
            : nil
            VStack(alignment: .leading) {
                Text(transaction.category.name)
                Text(transaction.comment ?? "")
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(transaction.amount.formatted(.currency(code: transaction.account.currency)))")
            Image(systemName: "chevron.right")
                .foregroundStyle(Color.gray)
        }
    }
}

#Preview("outcome") {
    TransactionsListView(direction: .outcome)
}

#Preview("income") {
    TransactionsListView(direction: .income)
}
