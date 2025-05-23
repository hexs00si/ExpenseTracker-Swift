import UIKit
import SwiftUI
import Combine

class DashboardViewController: UIViewController {
    // MARK: - Properties
    private let expenseManager: ExpenseManager
    private var cancellables = Set<AnyCancellable>()
    private var selectedCategory: ExpenseCategory?
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let tableView = UITableView()
    private let collectionView: UICollectionView
    private let totalExpensesLabel = UILabel()
    private let chartView = ExpenseChartView()
    
    // MARK: - Initializer
    init(expenseManager: ExpenseManager) {
        self.expenseManager = expenseManager
        let layout = DashboardViewController.createCompositionalLayout()
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update table view height dynamically based on content
        let expenses = selectedCategory == nil ? expenseManager.recentExpenses(limit: 10) : expenseManager.expenses(for: selectedCategory)
        let tableViewHeight = CGFloat(expenses.count) * 76 + 50 // 76 per row + 50 for header
        tableView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = tableViewHeight
            }
        }
        // Update chart data
        updateChart()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        // Navigation Bar
        navigationItem.title = "Expense Tracker"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(addExpenseTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = .systemBlue
        
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Content View
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Total Expenses Label
        totalExpensesLabel.font = .systemFont(ofSize: 22, weight: .medium)
        totalExpensesLabel.textColor = .secondaryLabel
        totalExpensesLabel.text = "Total: \(formatCurrency(expenseManager.totalExpenses()))"
        totalExpensesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Chart View
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.backgroundColor = .clear
        
        // Collection View
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false // Disable scrolling, let main scroll view handle it
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.identifier)
        collectionView.register(
            TotalExpensesHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TotalExpensesHeader.identifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        
        // Table View
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ExpenseCell.self, forCellReuseIdentifier: ExpenseCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.rowHeight = 76 // Fixed row height to match ExpenseRowView
        
        // Add subviews to content view
        contentView.addSubview(totalExpensesLabel)
        contentView.addSubview(chartView)
        contentView.addSubview(collectionView)
        contentView.addSubview(tableView)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Total Expenses Label
            totalExpensesLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            totalExpensesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            totalExpensesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            totalExpensesLabel.heightAnchor.constraint(equalToConstant: 30),
            
            // Chart View
            chartView.topAnchor.constraint(equalTo: totalExpensesLabel.bottomAnchor, constant: 20),
            chartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            chartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chartView.heightAnchor.constraint(equalToConstant: 200),
            
            // Collection View
            collectionView.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Table View
            tableView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 500) // Will be updated dynamically
        ])
        
        // Dynamically calculate collection view height based on number of items
        let columns = UIDevice.current.userInterfaceIdiom == .pad ? 4 : UIDevice.current.orientation.isLandscape ? 3 : 2
        let rows = Int(ceil(Double(ExpenseCategory.allCases.count) / Double(columns)))
        let collectionViewHeight = CGFloat(rows) * 128 // 120 (item height) + 8 (insets)
        collectionView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = collectionViewHeight
            }
        }
        collectionView.heightAnchor.constraint(equalToConstant: collectionViewHeight).isActive = true
    }
    
    private func setupBindings() {
        // Subscribe to expenseManager updates
        expenseManager.$expenses
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateUI()
            }
            .store(in: &cancellables)
    }
    
    private func updateUI() {
        totalExpensesLabel.text = "Total: \(formatCurrency(expenseManager.totalExpenses()))"
        tableView.reloadData()
        collectionView.reloadData()
        updateChart()
        view.setNeedsLayout() // Update table view height
    }
    
    private func updateChart() {
        var categoryData: [String: Double] = [:]
        for category in ExpenseCategory.allCases {
            let amount = expenseManager.totalExpenses(for: category)
            categoryData[category.rawValue] = amount
        }
        chartView.update(with: categoryData)
    }
    
    // MARK: - Actions
    @objc private func addExpenseTapped() {
        let addExpenseView = AddExpenseView()
            .environmentObject(expenseManager)
        let hostingController = UIHostingController(rootView: addExpenseView)
        present(hostingController, animated: true, completion: nil)
    }
    
    @objc private func clearFilterTapped() {
        selectedCategory = nil
        tableView.reloadData()
        collectionView.reloadData()
        // Scroll to top of table view
        if !tableView.visibleCells.isEmpty {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    // MARK: - Helpers
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter.currency
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    // MARK: - Compositional Layout
    static func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            // Determine number of columns based on device and orientation
            let isLandscape = environment.container.effectiveContentSize.width > environment.container.effectiveContentSize.height
            let isIPad = UIDevice.current.userInterfaceIdiom == .pad
            let columns = isIPad ? 4 : isLandscape ? 3 : 2
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0 / CGFloat(columns)),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(120)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            // Add Header
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(40)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
            
            return section
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension DashboardViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let expenses = selectedCategory == nil ? expenseManager.recentExpenses(limit: 10) : expenseManager.expenses(for: selectedCategory)
        return expenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExpenseCell.identifier, for: indexPath) as! ExpenseCell
        let expenses = selectedCategory == nil ? expenseManager.recentExpenses(limit: 10) : expenseManager.expenses(for: selectedCategory)
        let expense = expenses[indexPath.row]
        cell.configure(with: expense)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let expenses = selectedCategory == nil ? expenseManager.recentExpenses(limit: 10) : expenseManager.expenses(for: selectedCategory)
        let expense = expenses[indexPath.row]
        print("Selected expense: \(expense.description) - \(expense.amount)")
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.text = selectedCategory == nil ? "Recent Expenses" : "\(selectedCategory!.rawValue) Expenses (Filtered)"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)
        
        if selectedCategory != nil {
            let clearButton = UIButton(type: .system)
            clearButton.setTitle("Clear Filter", for: .normal)
            clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            clearButton.tintColor = .systemBlue
            clearButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            clearButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
            clearButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10) // Add padding
            clearButton.translatesAutoresizingMaskIntoConstraints = false
            clearButton.addTarget(self, action: #selector(clearFilterTapped), for: .touchUpInside)
            clearButton.accessibilityLabel = "Clear category filter"
            headerView.addSubview(clearButton)
            
            NSLayoutConstraint.activate([
                clearButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
                clearButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                clearButton.heightAnchor.constraint(equalToConstant: 30)
            ])
            
            // Ensure titleLabel doesn't overlap with clearButton
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
                titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: clearButton.leadingAnchor, constant: -10),
                titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
                titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
            ])
        } else {
            // When there's no clearButton, titleLabel can take full width
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
                titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
                titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
            ])
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension DashboardViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ExpenseCategory.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.identifier, for: indexPath) as! CategoryCell
        let category = ExpenseCategory.allCases[indexPath.item]
        let amount = expenseManager.totalExpenses(for: category)
        cell.configure(with: category, amount: amount, isSelected: selectedCategory == category)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TotalExpensesHeader.identifier,
            for: indexPath
        ) as! TotalExpensesHeader
        header.configure(with: "Expenses by Category")
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = ExpenseCategory.allCases[indexPath.item]
        selectedCategory = (selectedCategory == category) ? nil : category
        tableView.reloadData()
        collectionView.reloadData()
        
        // Scroll to top of table view
        if !tableView.visibleCells.isEmpty {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
}

// MARK: - Custom Cells and Headers
class ExpenseCell: UITableViewCell {
    static let identifier = "ExpenseCell"
    private var hostingController: UIHostingController<ExpenseRowView>?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with expense: Expense) {
        // Remove old hosting controller if exists
        hostingController?.view.removeFromSuperview()
        hostingController = nil
        
        // Create new hosting controller with ExpenseRowView
        let expenseRowView = ExpenseRowView(expense: expense)
        let hostingController = UIHostingController(rootView: expenseRowView)
        self.hostingController = hostingController
        
        guard let hostingView = hostingController.view else { return }
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.backgroundColor = .clear
        contentView.addSubview(hostingView)
        
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hostingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            hostingView.heightAnchor.constraint(equalToConstant: 76) // Match ExpenseRowView height
        ])
    }
}

class CategoryCell: UICollectionViewCell {
    static let identifier = "CategoryCell"
    private var hostingController: UIHostingController<CategoryCardView>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with category: ExpenseCategory, amount: Double, isSelected: Bool) {
        // Remove old hosting controller if exists
        hostingController?.view.removeFromSuperview()
        hostingController = nil
        
        // Create new hosting controller with CategoryCardView
        let categoryCardView = CategoryCardView(category: category, amount: amount, isSelected: isSelected)
        let hostingController = UIHostingController(rootView: categoryCardView)
        self.hostingController = hostingController
        
        guard let hostingView = hostingController.view else { return }
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hostingView)
        
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hostingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

class TotalExpensesHeader: UICollectionReusableView {
    static let identifier = "TotalExpensesHeader"
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func configure(with title: String) {
        label.text = title
    }
}

// MARK: - Custom Chart View
class ExpenseChartView: UIView {
    private var categoryData: [String: Double] = [:]
    private let barLayer = CALayer()
    private let xAxisLayer = CALayer()
    private let yAxisLayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayers() {
        layer.addSublayer(barLayer)
        layer.addSublayer(xAxisLayer)
        layer.addSublayer(yAxisLayer)
    }
    
    func update(with data: [String: Double]) {
        categoryData = data
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        barLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        xAxisLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        yAxisLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let chartHeight = rect.height - 50 // Leave space for x-axis labels
        let chartWidth = rect.width - 50 // Leave space for y-axis labels
        let barSpacing: CGFloat = 10
        let numberOfBars = CGFloat(categoryData.count)
        let barWidth = (chartWidth - (numberOfBars - 1) * barSpacing) / numberOfBars
        
        // Find max amount for scaling
        let maxAmount = categoryData.values.max() ?? 1.0
        let scale = (maxAmount > 0) ? (chartHeight - 20) / maxAmount : 0
        
        // Draw bars
        var index: CGFloat = 0
        for (category, amount) in categoryData.sorted(by: { $0.key < $1.key }) {
            let barHeight = CGFloat(amount) * scale
            let barX = 50 + index * (barWidth + barSpacing)
            let barY = chartHeight - barHeight
            
            let bar = CALayer()
            bar.frame = CGRect(x: barX, y: barY, width: barWidth, height: barHeight)
            bar.backgroundColor = UIColor.systemBlue.cgColor
            bar.cornerRadius = 4
            barLayer.addSublayer(bar)
            
            // X-axis label
            let xLabel = CATextLayer()
            xLabel.string = category
            xLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium) as CFTypeRef
            xLabel.fontSize = 12
            xLabel.foregroundColor = UIColor.label.cgColor
            xLabel.alignmentMode = .center
            xLabel.frame = CGRect(x: barX, y: chartHeight + 5, width: barWidth, height: 20)
            xLabel.contentsScale = UIScreen.main.scale
            xAxisLayer.addSublayer(xLabel)
            
            index += 1
        }
        
        // Draw Y-axis labels (amounts)
        let stepCount = 5
        let stepValue = maxAmount / Double(stepCount)
        for i in 0...stepCount {
            let amount = Double(i) * stepValue
            let yPosition = chartHeight - CGFloat(amount) * scale
            
            let yLabel = CATextLayer()
            yLabel.string = String(format: "$%.0f", amount)
            yLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium) as CFTypeRef
            yLabel.fontSize = 12
            yLabel.foregroundColor = UIColor.label.cgColor
            yLabel.alignmentMode = .right
            yLabel.frame = CGRect(x: 0, y: yPosition - 10, width: 40, height: 20)
            yLabel.contentsScale = UIScreen.main.scale
            yAxisLayer.addSublayer(yLabel)
            
            // Draw grid line
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 50, y: yPosition))
            path.addLine(to: CGPoint(x: rect.width, y: yPosition))
            let gridLine = CAShapeLayer()
            gridLine.path = path.cgPath
            gridLine.strokeColor = UIColor.gray.withAlphaComponent(0.2).cgColor
            gridLine.lineWidth = 1
            yAxisLayer.addSublayer(gridLine)
        }
    }
}
