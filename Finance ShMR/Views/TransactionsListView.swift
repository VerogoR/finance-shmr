import SwiftUI

struct TransactionsListView: View {
    
    @State private var todaysTransactions: [Transaction] = []
    @State private var transactionService: TransactionsService?
    
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
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("Всего")
                        Spacer()
                        Text(String(todayTransactionsValue.formatted(.currency(code: transactionService?.account.currency ?? "RUB"))))
                    }
                }
                Section(header: Text("Операции")) {
                    ForEach(todaysTransactions.filter( { $0.category.direction == direction } )) { transaction in
                        TransactionTab(transaction: transaction)
                    }
                }
            }
            .task {
                await initializeService()
                await loadTodaysTransactions()
            }
            .navigationTitle("\(direction == .income ? "Доходы" : "Расходы") сегодня")
            .toolbar {
                Button {
                    
                } label: {
                    Image(systemName: "clock")
                        .foregroundStyle(Color.indigo)
                }
            }
        }
    }
    
    private func initializeService() async {
        transactionService = await TransactionsService()
    }
    
    private func loadTodaysTransactions() async {
        guard let transactionService else { return }
        let today = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: today)!
        todaysTransactions = await transactionService.transactions(for: today...endOfDay)
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
            
        }
    }
}

#Preview("outcome") {
    TransactionsListView(direction: .outcome)
}

#Preview("income") {
    TransactionsListView(direction: .income)
}

/*
 Section(header: Text("Операции")) {
     ScrollView {
         LazyVStack(spacing: 0) {
             ForEach(todaysTransactions.filter { $0.category.direction == direction }) { transaction in
                 TransactionTab(transaction: transaction)
                     .padding(.vertical, 8)
                     .padding(.horizontal, 20)
             }
         }
     }
     .listRowInsets(EdgeInsets())
 }
 */
