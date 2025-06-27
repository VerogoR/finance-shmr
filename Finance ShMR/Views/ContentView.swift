import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Расходы", image: "outcomeTabIcon") {
                TransactionsListView(direction: .outcome)
            }
            Tab("Доходы", image: "incomeTabIcon") {
                TransactionsListView(direction: .income)
            }
            Tab("Счет", image: "accountTabIcon") {
                AccountView()
            }
            Tab("Статьи", image: "categoriesTabIcon") {
                Text("Статьи")
            }
            Tab("Настройки", image: "settingsTabIcon") {
                Text("Настройки")
            }
        }
    }
}

#Preview {
    ContentView()
}
