import SwiftUI

struct ContentView: View {
    @State private var isAnimationFinished = false
    
    private var MainView: some View {
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
                CategoryView()
            }
            Tab("Настройки", image: "settingsTabIcon") {
                Text("Настройки")
            }
        }
    }
    
    var body: some View {
        Group {
            if isAnimationFinished {
                MainView
            } else {
                LaunchAnimationView(animationName: "animation") {
                    isAnimationFinished = true
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
