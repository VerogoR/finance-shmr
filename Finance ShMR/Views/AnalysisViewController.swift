import UIKit

class AnalysisViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let amountLabel = UILabel()
    private let startDatePicker = UIDatePicker()
    private let endDatePicker = UIDatePicker()
    
    private enum SortOption {
        case date
        case amount
    }

    private var currentSort: SortOption = .date
    
    private var transactionsService = TransactionsService()
    var direction: Direction = .outcome
    private var transactions: [Transaction] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Анализ"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(dismissView))
        startDatePicker.datePickerMode = .date
        startDatePicker.date = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        startDatePicker.preferredDatePickerStyle = .compact
        startDatePicker.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)
        
        endDatePicker.datePickerMode = .date
        endDatePicker.date = Date()
        endDatePicker.preferredDatePickerStyle = .compact
        endDatePicker.addTarget(self, action: #selector(endDateChanged), for: .valueChanged)
        
        sortSegmentedControl.addTarget(self, action: #selector(sortChanged), for: .valueChanged)

        setupTableView()
        Task {
            await loadTransactions()
        }
    }
    
    @objc private func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private let sortSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Дата", "Сумма"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(OperationCell.self, forCellReuseIdentifier: "OperationCell")
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Header as Section Header
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 50
        }
        return 62
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Операции"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 40
    }
    
    private func createPickerField(label: String, picker: UIDatePicker) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = UIFont.systemFont(ofSize: 18)
        let stack = UIStackView(arrangedSubviews: [labelView, picker])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        return stack
    }
    
    // MARK: - Table Sections & Rows
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        } else {
            return transactions.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.selectionStyle = .none
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }

            switch indexPath.row {
            case 0:
                let stack = createDateStack(nlabel: "Период: начало", picker: startDatePicker)
                cell.contentView.addSubview(stack)
                setupStackConstraints(stack, in: cell.contentView)

            case 1:
                let stack = createDateStack(nlabel: "Период: конец", picker: endDatePicker)
                cell.contentView.addSubview(stack)
                setupStackConstraints(stack, in: cell.contentView)

            case 2:
                cell.contentView.addSubview(sortSegmentedControl)
                NSLayoutConstraint.activate([
                    sortSegmentedControl.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                    sortSegmentedControl.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                    sortSegmentedControl.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
                    sortSegmentedControl.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8)
                ])
                
            default:
                let titleLabel = UILabel()
                titleLabel.text = "Сумма"
                titleLabel.font = .systemFont(ofSize: 16)
                
                let stack = UIStackView(arrangedSubviews: [titleLabel, amountLabel])
                stack.axis = .horizontal
                stack.distribution = .equalSpacing
                stack.alignment = .center
                
                cell.contentView.addSubview(stack)
                setupStackConstraints(stack, in: cell.contentView)
            }
            
            return cell
        } else {
            let transaction = transactions[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "OperationCell", for: indexPath) as! OperationCell
            
            let total = transactions.reduce(Decimal(0)) { $0 + $1.amount }
            let percentage: Int
            if total > 0 {
                let fraction = (transaction.amount / total * 100 as NSDecimalNumber).doubleValue
                percentage = Int(round(fraction))
            } else {
                percentage = 0
            }
            
            let icon = String(transaction.category.emoji)
            let backgroundColor = UIColor(.accentColor.opacity(0.2))
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = transaction.account.currency
            formatter.locale = Locale.current
            let amountString = formatter.string(from: transaction.amount as NSDecimalNumber) ?? "\(transaction.amount)"
            
            cell.configure(
                icon: icon,
                title: transaction.category.name,
                subtitle: transaction.comment,
                amount: amountString,
                percent: percentage,
                backgroundColor: backgroundColor
            )
            
            return cell
        }
    }
    
    private func createDateStack(nlabel: String, picker: UIDatePicker) -> UIStackView {
        let label = UILabel()
        label.text = nlabel
        label.font = .systemFont(ofSize: 16)
        
        let stack = UIStackView(arrangedSubviews: [label, picker])
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }
    
    private func setupStackConstraints(_ stack: UIStackView, in view: UIView) {
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Data
    
    @objc private func startDateChanged() {
        if startDatePicker.date > endDatePicker.date {
            endDatePicker.setDate(startDatePicker.date, animated: true)
        }
        Task { await loadTransactions() }
    }
    
    @objc private func endDateChanged() {
        if endDatePicker.date < startDatePicker.date {
            startDatePicker.setDate(endDatePicker.date, animated: true)
        }
        Task { await loadTransactions() }
    }
    
    private func periodRange() -> ClosedRange<Date> {
        let start = Calendar.current.startOfDay(for: startDatePicker.date)
        let end = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endDatePicker.date)!
        return start...end
    }
    
    
    @objc private func sortChanged() {
        currentSort = sortSegmentedControl.selectedSegmentIndex == 0 ? .date : .amount
        transactions.sort {
            switch currentSort {
            case .date:
                return $0.transactionDate > $1.transactionDate
            case .amount:
                return $0.amount > $1.amount
            }
        }
        tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
    }
    
    
    private func loadTransactions() async {
        let range = periodRange()
        let all = await transactionsService.transactions(for: range)
        self.transactions = all.filter { $0.category.direction == direction }
        switch currentSort {
        case .date:
            self.transactions.sort { $0.transactionDate > $1.transactionDate }
        case .amount:
            self.transactions.sort { $0.amount > $1.amount }
        }

        DispatchQueue.main.async {
            self.updateTotalAmount()
            self.tableView.reloadData()
        }
    }
    
    private func updateTotalAmount() {
        let total = transactions.reduce(Decimal(0)) { $0 + $1.amount }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = transactions.first?.account.currency ?? "RUB"
        formatter.locale = Locale(identifier: "ru_RU")
        amountLabel.text = formatter.string(from: NSDecimalNumber(decimal: total))
    }
}

final class OperationCell: UITableViewCell {
    
    private let iconBackground = UIView()
    private let iconLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let percentLabel = UILabel()
    private let amountLabel = UILabel()
    
    private let verticalStack = UIStackView()
    private let trailingStack = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        iconBackground.translatesAutoresizingMaskIntoConstraints = false
        iconBackground.backgroundColor = .systemGray5
        iconBackground.layer.cornerRadius = 19
        iconBackground.clipsToBounds = true
        
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.font = UIFont.systemFont(ofSize: 20)
        iconLabel.textAlignment = .center
        
        iconBackground.addSubview(iconLabel)
        NSLayoutConstraint.activate([
            iconBackground.widthAnchor.constraint(equalToConstant: 38),
            iconBackground.heightAnchor.constraint(equalToConstant: 38),
            iconLabel.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor)
        ])
        
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        
        percentLabel.font = UIFont.systemFont(ofSize: 16)
        percentLabel.textAlignment = .right
        
        amountLabel.font = UIFont.systemFont(ofSize: 16)
        amountLabel.textAlignment = .right
        
        verticalStack.axis = .vertical
        verticalStack.spacing = 2
        verticalStack.addArrangedSubview(titleLabel)
        verticalStack.addArrangedSubview(subtitleLabel)
        
        trailingStack.axis = .vertical
        trailingStack.alignment = .trailing
        trailingStack.spacing = 2
        trailingStack.addArrangedSubview(percentLabel)
        trailingStack.addArrangedSubview(amountLabel)
        
        let mainStack = UIStackView(arrangedSubviews: [iconBackground, verticalStack, trailingStack])
        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(icon: String, title: String, subtitle: String?, amount: String, percent: Int, backgroundColor: UIColor) {
        iconLabel.text = icon
        iconBackground.backgroundColor = backgroundColor
        titleLabel.text = title
        subtitleLabel.text = subtitle
        amountLabel.text = amount
        percentLabel.text = "\(percent)%"
    }
}
