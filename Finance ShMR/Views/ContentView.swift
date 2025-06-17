import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Расходы", image: "outcomeTabIcon") {
                Text("Расходы")
            }
            Tab("Доходы", image: "incomeTabIcon") {
                Text("Доходы")
            }
            Tab("Счет", image: "accountTabIcon") {
                Text("Счет")
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
