import UIKit

class TextFieldWithPadding: UITextField {
    var textPadding = UIEdgeInsets(
        top: 0,
        left: 16,
        bottom: 0,
        right: 16
    )
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }
}

protocol NewTrackerViewControllerDelegate: AnyObject {
    func didCreateNewTracker(_ tracker: Tracker, for categoryName: String)
}

final class NewTrackerViewController: UIViewController {
    
    weak var delegate: NewTrackerViewControllerDelegate?
    
    private var selectedSchedule: [DayOfWeek] = []
    private let maxLength = 38
    private let emojiArray = Emojis.allCases
    private var selectedEmojiIndexPath: IndexPath?
    private var selectedColorIndexPath: IndexPath?
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private let textField = TextFieldWithPadding()
    
    private lazy var emojiAndColorColletionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        
        collectionView.allowsMultipleSelection = false
        
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.reuseIdentifier)
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier)
        
        collectionView.register(
            EmojiAndColorSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: EmojiAndColorSupplementaryView.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .redWarning
        label.textAlignment = .center
        label.text = "Ограничение 38 символов"
        label.isHidden = true
        return label
    }()
    
    private let optionsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отмена", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.red, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.cornerRadius = 16
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .grayButton
        button.layer.cornerRadius = 16
        button.isUserInteractionEnabled = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "Новая привычка"
        textField.delegate = self
        setupNavigationController()
        setupScrollViewAndContentView()
        setupViewsInContentView()
        setupTapGesture()
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
    
    private func setupScrollViewAndContentView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        let minHeightConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.safeAreaLayoutGuide.heightAnchor)
        minHeightConstraint.priority = .defaultLow
        minHeightConstraint.isActive = true
    }
    
    private func setupViewsInContentView(){
        contentView.addSubview(mainStackView)
        mainStackView.spacing = 24
        mainStackView.distribution = .fill
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
        
        let textSectionStack = UIStackView(arrangedSubviews: [textField, warningLabel])
        textSectionStack.axis = .vertical
        textSectionStack.spacing = 8
        textField.backgroundColor = .backgroundDay.withAlphaComponent(0.3)
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.clipsToBounds = true
        textField.layer.cornerRadius = 16
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.systemFont(ofSize: 17)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: "Введите название трекера", attributes: placeholderAttributes)
        textField.clearButtonMode = .whileEditing
        textField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        mainStackView.addArrangedSubview(textSectionStack)
        
        mainStackView.addArrangedSubview(optionsTableView)
        optionsTableView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        optionsTableView.isScrollEnabled = false
        
        optionsTableView.delegate = self
        optionsTableView.dataSource = self
        optionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        mainStackView.addArrangedSubview(emojiAndColorColletionView)
        mainStackView.addArrangedSubview(buttonStackView)
        
        mainStackView.setCustomSpacing(16, after: optionsTableView)
        mainStackView.setCustomSpacing(16, after: emojiAndColorColletionView)
        
        emojiAndColorColletionView.heightAnchor.constraint(equalToConstant: 500).isActive = true
        buttonStackView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        buttonStackView.addArrangedSubview(cancelButton)
        cancelButton.addTarget(self, action: #selector (cancelButtonTapped), for: .touchUpInside)
        buttonStackView.addArrangedSubview(createButton)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
    }
    
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func createLayout() -> UICollectionViewLayout{
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0/6.0),
            heightDimension: .fractionalWidth(1.0/6.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1.0/6.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 2, bottom: 24, trailing: 2)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(18))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        let trackerTitle = textField.text ?? ""
        let days = selectedSchedule
        guard let selectedColor = selectedColor else { return }
        guard let selectedEmoji = selectedEmoji else { return }
        let tracker = Tracker(title: trackerTitle, color: selectedColor, emoji: selectedEmoji, days: days)
        let categoryName = "Важное"
        
        delegate?.didCreateNewTracker(tracker, for: categoryName)
        dismiss(animated: true)
    }
}

extension NewTrackerViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString = textField.text ?? ""
        guard let rangeToReplace = Range(range, in: currentString) else { return false }
        let newString = currentString.replacingCharacters(in: rangeToReplace, with: string)
        warningLabel.isHidden = newString.count < maxLength
        return newString.count <= maxLength
    }
}

extension NewTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            print("Нажали на Категорию")
        } else {
            let cell = tableView.cellForRow(at: indexPath)
            let selectedStates = cell?.detailTextLabel?.text
            let scheduleVC = ScheduleViewController(selectedStates:selectedStates)
            scheduleVC.delegate = self
            let navigationVC = UINavigationController(rootViewController: scheduleVC)
            navigationVC.modalPresentationStyle = .popover
            present(navigationVC, animated: true)
        }
    }
}

extension NewTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.detailTextLabel?.textColor = .gray
        if indexPath.row == 0 {
            cell.textLabel?.text = "Категория"
            cell.detailTextLabel?.text = "Важное"
        } else {
            cell.textLabel?.text = "Расписание"
            if selectedSchedule.count == 7 {
                cell.detailTextLabel?.text = "Каждый день"
            } else {
                let shortNames = selectedSchedule.map { $0.shortName }
                cell.detailTextLabel?.text = shortNames.joined(separator: ", ")
            }
        }
        
        cell.accessoryType = .disclosureIndicator
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

extension NewTrackerViewController: ScheduleViewControllerDelegate{
    func didUpdateSchedule(_ selectedDays: [DayOfWeek]) {
        self.selectedSchedule = selectedDays
        self.optionsTableView.reloadData()
        self.createButton.backgroundColor = .blackDay
        self.createButton.isUserInteractionEnabled = true
    }
}

extension NewTrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let previousIndexPath = selectedEmojiIndexPath {
                let previousCell = collectionView.cellForItem(at: previousIndexPath) as? EmojiCollectionViewCell
                previousCell?.changeSelection(false)
            }
            let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell
            cell?.changeSelection(true)
            selectedEmojiIndexPath = indexPath
            selectedEmoji = emojiArray[indexPath.row].rawValue
            
        } else if indexPath.section == 1 {
            if let previousIndexPath = selectedColorIndexPath {
                let previousCell = collectionView.cellForItem(at: previousIndexPath) as? ColorCollectionViewCell
                previousCell?.changeSelection(false)
            }
            let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell
            cell?.changeSelection(true)
            selectedColorIndexPath = indexPath
            selectedColor = availableColors[indexPath.row].uiColor
        }
    }
}

extension NewTrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 18
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier, for: indexPath) as! EmojiCollectionViewCell
            
            let emoji = emojiArray[indexPath.row].rawValue
            cell.configure(emoji: emoji)
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.reuseIdentifier, for: indexPath) as! ColorCollectionViewCell
            
            let color = availableColors[indexPath.row].uiColor
            cell.configure(color: color)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: EmojiAndColorSupplementaryView.identifier,
            for: indexPath
        ) as? EmojiAndColorSupplementaryView else {
            return UICollectionReusableView()
        }
        
        if indexPath.section == 0 {
            header.titleLabel.text = "Emoji"
        } else {
            header.titleLabel.text = "Цвет"
        }
        
        return header
    }
}
