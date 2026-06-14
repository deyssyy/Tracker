import UIKit

protocol FilterViewControllerDelegate: AnyObject{
    func didUpdateFilter(filter: FilterType)
}

final class FilterViewController: UIViewController{
    let filters = FilterType.allCases
    
    var currentFilter: FilterType
    weak var delegate: FilterViewControllerDelegate?
    
    private let filtersTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        
        return tableView
    }()
    
    init(currentFilter: FilterType) {
        self.currentFilter = currentFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "filter_vc_label_title".localized
        view.backgroundColor = .whiteNight
        setupNavigationController()
        setupFiltersTableView()
    }
    
    private func setupNavigationController(){
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.blackDay,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        
        appearance.largeTitleTextAttributes = textAttributes
        appearance.titleTextAttributes = textAttributes
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        navigationController?.navigationBar.isTranslucent = true
    }
    
    private func setupFiltersTableView(){
        filtersTableView.register(UITableViewCell.self, forCellReuseIdentifier: "filterCell")
        view.addSubview(filtersTableView)
        
        NSLayoutConstraint.activate([
            filtersTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            filtersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filtersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filtersTableView.heightAnchor.constraint(equalToConstant: CGFloat(filters.count * 75))
        ])
        
        filtersTableView.delegate = self
        filtersTableView.dataSource = self
    }
}

extension FilterViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedFilter = FilterType(rawValue: indexPath.row) else { return }
        self.currentFilter = selectedFilter
        delegate?.didUpdateFilter(filter: currentFilter)
        if indexPath.row > 1{
            guard let cell = tableView.cellForRow(at: indexPath) else { return }
            cell.accessoryType = .checkmark
        }
        dismiss(animated: true)
    }
}

extension FilterViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = filtersTableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath)
        cell.textLabel?.text = filters[indexPath.row].title
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        cell.backgroundColor = .backgroundDay.withAlphaComponent(0.3)
        
        if currentFilter.rawValue > 1 && indexPath.row == currentFilter.rawValue {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        cell.selectionStyle = .none
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width + 100)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        return cell
    }
}
