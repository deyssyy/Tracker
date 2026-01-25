import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didUpdateSchedule(_ selectedDays: [DayOfWeek])
}

final class ScheduleViewController: UIViewController{
    
    private let days: [DayOfWeek] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    private var selectedStates: [Bool] = []
    private var selectedStateStringArray: [String]
    
    weak var delegate: ScheduleViewControllerDelegate?
    
    init(selectedStates: String?){
        self.selectedStateStringArray = []
        super.init(nibName: nil, bundle: nil)
        
        convertSelectedStatesStringToBoolArray(selectedStatesString: selectedStates)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func convertSelectedStatesStringToBoolArray(selectedStatesString: String?){
        guard let string = selectedStatesString else {
            selectedStates = Array(repeating: false, count: 7)
            return
        }
        let incomingDays = string.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        self.selectedStateStringArray = incomingDays
        
        selectedStates = days.map { day in
            incomingDays.contains(day.shortName)
        }
    }
    
    private let scheduleTable: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    private let aproveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blackDay
        button.layer.cornerRadius = 16
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "Расписание"
        setupNavigationController()
        setupButton()
        setupTableView()
    }
    
    private func setupNavigationController(){
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.blackDay,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.blackDay,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    private func setupButton(){
        aproveButton.addTarget(self, action: #selector(aproveButtonTapped), for: .touchUpInside)
        aproveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(aproveButton)
        
        NSLayoutConstraint.activate([
            aproveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            aproveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            aproveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            aproveButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupTableView(){
        scheduleTable.register(UITableViewCell.self, forCellReuseIdentifier: "dayCell")
        view.addSubview(scheduleTable)
        
        NSLayoutConstraint.activate([
            scheduleTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            scheduleTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scheduleTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scheduleTable.heightAnchor.constraint(equalToConstant: 525)
        ])
        
        scheduleTable.dataSource = self
        scheduleTable.delegate = self
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        let index = sender.tag
        selectedStates[index] = sender.isOn
    }
    
    @objc private func aproveButtonTapped(){
        var selectedDays: [DayOfWeek] = []
        
        for (index, isSelected) in selectedStates.enumerated() {
            if isSelected {
                selectedDays.append(days[index])
            }
        }
        
        delegate?.didUpdateSchedule(selectedDays)
        dismiss(animated: true)
    }
}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath)
        
        cell.textLabel?.text = days[indexPath.row].fullName
        let switchControl = UISwitch()
        switchControl.onTintColor = .systemBlue
        switchControl.isOn = selectedStates[indexPath.row]
        switchControl.tag = indexPath.row
        switchControl.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        
        cell.accessoryView = switchControl
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        cell.backgroundColor = .backgroundDay.withAlphaComponent(0.3)
        
        cell.selectionStyle = .none
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width + 100)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        return cell
    }
}

extension ScheduleViewController: UITableViewDelegate {
}
