import SwiftUI

struct TransactionsListView: View {
    
    @State private var todaysTransactions: [Transaction] = []
    
    let direction: Direction
    
    init(direction: Direction) {
        self.direction = direction
    }
    
    var transactionService = TransactionsService()
    
    private let calendar = Calendar.current
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Text("Всего")
                }
                Section(header: Text("Операции")) {
                    ForEach(todaysTransactions) {transaction in
                        Text(transaction.categoryId)
                    }
                }
            }
            .task {
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
    
    private func loadTodaysTransactions() async {
        let today = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: today)!
        todaysTransactions = await transactionService.transactions(for: today...endOfDay)
    }
    
}

#Preview {
    TransactionsListView(direction: .income)
}
