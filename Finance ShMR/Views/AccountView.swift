import SwiftUI

struct AccountView: View {
    @StateObject private var viewModel = AccountViewModel()
    @State private var isEditing = false
    @State private var showKeyboard = false
    @State private var showCurrencyPicker = false

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.account != nil {
                    List {
                        Section {
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
                        Section {
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
                    }
                    .refreshable {
                        await viewModel.fetchAccount()
                    }
                } else {
                    ProgressView("Загрузка...")
                        .task {
                            await viewModel.fetchAccount()
                        }
                }
            }
            .navigationTitle("Мой счёт")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            if isEditing {
                                await viewModel.saveChanges()
                            }
                            isEditing.toggle()
                        }
                    } label: {
                        Text(isEditing ? "Сохранить" : "Редактировать")
                            .foregroundStyle(Color.indigo)
                    }
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
