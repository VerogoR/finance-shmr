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
    
    var ChartPicker: some View {
        Picker("", selection: $viewModel.chartPeriod) {
            ForEach(ChartPeriod.allCases) {
                Text($0.title).tag($0)
            }
        }
        .pickerStyle(.segmented)
        .scaleEffect(x: 1.35, y: 1.35, anchor: .center)
        .padding(.horizontal, 27)
    }
    
    var ChartView: some View {
        AccountChartView(
            points: viewModel.points,
            period: viewModel.chartPeriod
        )
        .frame(height: 230)
        .padding(.horizontal, -14)
        .listRowBackground(Color.clear)
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
                        if !isEditing {
                            Section {
                                ChartPicker
                                    .listRowBackground(Color.clear)
                                    .onAppear {
                                        let font = UIFont.systemFont(ofSize: 11)
                                        let attrs: [NSAttributedString.Key: Any] = [
                                            .font: font,
                                            .foregroundColor: UIColor.label
                                        ]
                                        UISegmentedControl.appearance().setTitleTextAttributes(attrs, for: .normal)
                                        UISegmentedControl.appearance().setTitleTextAttributes(attrs, for: .selected)
                                    }
                            }
                            Section {
                                ChartView
                            }
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .refreshable {
                        await fetchAccountWithAlert()
                    }
                } else {
                    ProgressView("Загрузка...")
                }
            }
            .task {
                await fetchAccountWithAlert()
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
            try await viewModel.updateDayMonthPoints()
        } catch {
            print(error)
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
