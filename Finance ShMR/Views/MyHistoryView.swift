import SwiftUI

struct MyHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    
    private var calendar = Calendar.current
    
    let direction: Direction
    
    @State private var endPeriod: Date
    @State private var startPeriod: Date
    @State private var periodTransactions: [Transaction] = []
    @State private var transactionService = TransactionsService()
    
    init(direction: Direction) {
        self.direction = direction
        
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: todayStart)!
        let monthAgoStart = calendar.date(byAdding: .month, value: -1, to: todayStart)! 
        
        _endPeriod = State(initialValue: endOfToday)
        _startPeriod = State(initialValue: monthAgoStart)
    }
    
    var periodTransactionsValue: Decimal {
        let correctDirectionTransactions: [Transaction] = periodTransactions.filter( { $0.category.direction == direction } )
        return correctDirectionTransactions.reduce(0) { result, transaction in
            result + transaction.amount
        }
    }
    
    private var datePickersSection: some View {
        Section {
            HStack {
                Text("Начало")
                Spacer()
                DatePicker("", selection: $startPeriod, displayedComponents: .date)
                    .colorMultiply(.accentColor)
            }
            HStack {
                Text("Конец")
                Spacer()
                DatePicker("", selection: Binding(
                    get: { endPeriod },
                    set: { newValue in
                        endPeriod = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: newValue)!
                    }
                ), displayedComponents: .date)
                .colorMultiply(.accentColor)
            }
            HStack {
                Text("Сумма")
                Spacer()
                Text(periodTransactionsValue.formatted(.currency(code: periodTransactions.first?.account.currency ?? "RUB")))
            }
        }
    }
    
    private var transactionsSection: some View {
        Section(header: Text("Операции")) {
            ForEach(periodTransactions.filter { $0.category.direction == direction }) { transaction in
                TransactionTab(transaction: transaction)
            }
        }
    }


    
    var body: some View {
        NavigationStack {
            List {
                datePickersSection
                transactionsSection
            }
            .task {
                await loadPeriodTransactions()
            }
            .onAppear {
                Task {
                    await loadPeriodTransactions()
                }
            }
            .onChange(of: startPeriod) {
                if startPeriod >= endPeriod {
                    endPeriod = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startPeriod)!
                }
                Task {
                    await loadPeriodTransactions()
                }
            }
            .onChange(of: endPeriod) {
                if startPeriod >= endPeriod {
                    startPeriod = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: endPeriod)!
                }
                Task {
                    await loadPeriodTransactions()
                }
            }
            .navigationTitle("Моя история")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Назад")
                            }
                            .foregroundStyle(.indigo)
                        }
                    }
                }
        }
    }
    
    private func loadPeriodTransactions() async {
        periodTransactions = await transactionService.transactions(for: startPeriod...endPeriod)
    }
}

#Preview {
    MyHistoryView(direction: .outcome)
}
