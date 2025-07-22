import SwiftUI

struct AccountView: View {
    @StateObject private var viewModel = AccountViewModel()
    @State private var isEditing = false
    @State private var showKeyboard = false
    @State private var showCurrencyPicker = false
    @State private var errorMessage: String?
    @State private var showErrorAlert = false
    
    var SaveButton: some View {
        Button {
            Task {
                if isEditing {
                    do {
                        try await viewModel.saveChanges()
                    } catch {
                        errorMessage = "Ошибка сохранения: \(error)"
                        showErrorAlert = true
                    }
                }
                isEditing.toggle()
                await fetchAccountWithAlert()
            }
        } label: {
            Text(isEditing ? "Сохранить" : "Редактировать")
                .foregroundStyle(Color.indigo)
        }
    }
    
    var BalanceSection: some View {
        HStack {
            Text("💰")
            Text("Баланс")
            Spacer()
            if isEditing {
                TextField("", text: $viewModel.balanceInput)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.gray)
                    .frame(maxWidth: 150)
            } else {
                if viewModel.isBalanceHidden {
                    Text("••••")
                        .transition(.opacity)
                } else {
                    Text(viewModel.balance)
                        .transition(.opacity)
                }
            }
        }
        .contentShape(Rectangle())
        .listRowBackground(isEditing ? Color.white : Color.accentColor)
    }
    
    var CurrencySection: some View {
        HStack {
            Text("Валюта")
            Spacer()
            Text(viewModel.selectedCurrencySymbol).foregroundStyle(isEditing ? Color.gray : Color.primary)
            isEditing ? Image(systemName: "chevron.right").foregroundStyle(Color.gray) : nil
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if isEditing {
                showCurrencyPicker = true
            }
        }
        .listRowBackground(isEditing ? Color.white : Color.accentColor.opacity(0.2))
    }

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.account != nil {
                    List {
                        Section {
                            BalanceSection
                        }
                        Section {
                            CurrencySection
                        }
                    }
                    .refreshable {
                        await fetchAccountWithAlert()
                    }
                } else {
                    ProgressView("Загрузка...")
                        .task {
                            await fetchAccountWithAlert()
                        }
                }
            }
            .navigationTitle("Мой счёт")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    SaveButton
                }
            }
            .alert("Ошибка", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
            .confirmationDialog("Выберите валюту", isPresented: $showCurrencyPicker, titleVisibility: .visible) {
                ForEach(Currency.allCases) { currency in
                    Button {
                        viewModel.selectedCurrency = currency
                        viewModel.saveCurrency()
                    } label: {
                        Text(currencyDisplayName(currency))
                    }
                }
            }

            .onShake {
                viewModel.toggleBalanceHidden()
            }
        }
    }
    func fetchAccountWithAlert() async {
        do {
            try await viewModel.fetchAccount()
        } catch {
            errorMessage = "Ошибка загрузки аккаунта: \(error)"
            showErrorAlert = true
        }
    }
    
    func currencyDisplayName(_ currency: Currency) -> String {
        switch currency {
        case .rub: return "Российский рубль ₽"
        case .usd: return "Американский доллар $"
        case .eur: return "Евро €"
        }
    }

}



#Preview {
    AccountView()
}
