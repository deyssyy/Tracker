import UIKit

enum TrackerMode {
    case create
    case edit(tracker: Tracker, categoryName: String, completedDays: Int, indexPath: IndexPath)
}

protocol NewTrackerViewControllerDelegate: AnyObject {
    func didCreateNewTracker(_ tracker: Tracker, for categoryName: String)
    func didCloseWithNoNewTracker()
    func didUpdateTracker(tracker: Tracker, for categoryName: String, indexPath: IndexPath)
}

final class NewTrackerViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
    
    weak var delegate: NewTrackerViewControllerDelegate?
    
    private var mode: TrackerMode = .create
    private var trackerToEdit: Tracker?
    private var indexPathOfTracker: IndexPath?
    private var collectionViewHeightConstraint: NSLayoutConstraint?
    private var selectedSchedule: [DayOfWeek] = []
    private let maxLength = 38
    private let emojiArray = Emojis.allCases
    private var selectedEmojiIndexPath: IndexPath?
    private var selectedColorIndexPath: IndexPath?
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var selectedCategoryName: String?
    private let textField = TextFieldWithPadding()
    
    private var isFormValid: Bool {
        let isTextValid = !(textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil
        let isCategorySelected = selectedCategoryName != nil
        let isScheduleValid = !selectedSchedule.isEmpty
        
        return isTextValid && isEmojiSelected && isColorSelected && isCategorySelected && isScheduleValid
    }
    
    private lazy var emojiAndColorCollectionView: UICollectionView = {
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
    
    private let daysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .blackDay
        label.textAlignment = .center
        label.isHidden = true
        return label
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
        button.isEnabled = false
        return button
    }()
    
    init(mode: TrackerMode = .create) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
        
        if case let .edit(tracker, category, _, indexPath) = mode {
            self.trackerToEdit = tracker
            self.selectedEmoji = tracker.emoji
            self.selectedColor = tracker.color
            self.selectedSchedule = tracker.days
            self.selectedCategoryName = category
            self.indexPathOfTracker = indexPath
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "Новая привычка"
        textField.delegate = self
        setupNavigationController()
        setupScrollViewAndContentView()
        setupViewsInContentView()
        setupTapGesture()
        configureEditMode()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        emojiAndColorCollectionView.layoutIfNeeded()
        
        collectionViewHeightConstraint?.constant = emojiAndColorCollectionView.collectionViewLayout.collectionViewContentSize.height
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        delegate?.didCloseWithNoNewTracker()
    }
    
    private func configureEditMode() {
        guard case let .edit(tracker, _, completedDays, _) = mode else { return }
        
        self.title = "Редактирование привычки"
        createButton.setTitle("Сохранить", for: .normal)
        textField.text = tracker.title
        
        daysLabel.text = "\(completedDays) дней"
        daysLabel.isHidden = false
        
        checkCreateButtonState()
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
    
    private func checkCreateButtonState(){
        let isValid = isFormValid
        
        createButton.isEnabled = isValid
        createButton.backgroundColor = isValid ? .blackDay : .gray
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
        
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        daysLabel.heightAnchor.constraint(equalToConstant: 38).isActive = true
        mainStackView.addArrangedSubview(daysLabel)
        mainStackView.setCustomSpacing(40, after: daysLabel)
        
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
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        mainStackView.addArrangedSubview(textSectionStack)
        
        mainStackView.addArrangedSubview(optionsTableView)
        optionsTableView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        optionsTableView.isScrollEnabled = false
        
        optionsTableView.delegate = self
        optionsTableView.dataSource = self
        optionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        mainStackView.addArrangedSubview(emojiAndColorCollectionView)
        mainStackView.addArrangedSubview(buttonStackView)
        
        mainStackView.setCustomSpacing(16, after: optionsTableView)
        mainStackView.setCustomSpacing(16, after: emojiAndColorCollectionView)
        
        collectionViewHeightConstraint = emojiAndColorCollectionView.heightAnchor.constraint(equalToConstant: 500)
        collectionViewHeightConstraint?.isActive = true
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
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        checkCreateButtonState()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func cancelButtonTapped() {
        delegate?.didCloseWithNoNewTracker()
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        let trackerTitle = textField.text ?? ""
        let days = selectedSchedule
        guard
            let selectedColor = selectedColor,
            let selectedEmoji = selectedEmoji
        else { return }
        
        let tracker = Tracker(id: trackerToEdit?.id ?? UUID(),title: trackerTitle, color: selectedColor, emoji: selectedEmoji, days: days)
        guard let categoryName = selectedCategoryName else { return }
        if case .edit = mode {
            guard let indexPath = indexPathOfTracker else { return }
            delegate?.didUpdateTracker(tracker: tracker, for: categoryName, indexPath: indexPath)
        } else {
            delegate?.didCreateNewTracker(tracker, for: categoryName)
        }
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
            let categoryStore = TrackerCategoryStore()
            let dataProvider = TrackerCategoryDataProvider(dataStore: categoryStore)
            
            let viewModel = TrackerViewModel(
                dataProvider: dataProvider,
                selectedCategoryName: self.selectedCategoryName
            )
            
            viewModel.onCategorySelected = { [weak self] categoryName in
                self?.selectedCategoryName = categoryName
                self?.optionsTableView.reloadData()
            }
            let categoryVC = CategoryViewController(viewModel: viewModel)
            let navigationVC = UINavigationController(rootViewController: categoryVC)
            navigationVC.modalPresentationStyle = .popover
            present(navigationVC, animated: true)
        } else {
            let cell = tableView.cellForRow(at: indexPath)
            var selectedStates = cell?.detailTextLabel?.text
            if selectedStates == "Каждый день"{
                selectedStates = "Пн, Вт, Ср, Чт, Пт, Сб, Вс"
            }
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
            cell.detailTextLabel?.text = selectedCategoryName
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
        self.checkCreateButtonState()
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
            checkCreateButtonState()
            
        } else if indexPath.section == 1 {
            if let previousIndexPath = selectedColorIndexPath {
                let previousCell = collectionView.cellForItem(at: previousIndexPath) as? ColorCollectionViewCell
                previousCell?.changeSelection(false)
            }
            let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell
            cell?.changeSelection(true)
            selectedColorIndexPath = indexPath
            selectedColor = availableColors[indexPath.row].uiColor
            checkCreateButtonState()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) else { return nil }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        
        return UITargetedPreview(view: cell, parameters: parameters)
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
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier, for: indexPath) as? EmojiCollectionViewCell
            else { return UICollectionViewCell() }
            
            let emoji = emojiArray[indexPath.row].rawValue
            cell.configure(emoji: emoji)
            
            if emoji == selectedEmoji {
                cell.changeSelection(true)
                //cell.isSelected = true
                selectedEmojiIndexPath = indexPath
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            } else {
                cell.changeSelection(false)
            }
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.reuseIdentifier, for: indexPath) as? ColorCollectionViewCell else { return UICollectionViewCell() }
            
            let color = availableColors[indexPath.row].uiColor
            cell.configure(color: color)
            
            let uiColorMarshalling = UIColorMarshalling()
            
            let colorString = uiColorMarshalling.serialize(color)
            let selectedColorString = selectedColor != nil ? uiColorMarshalling.serialize(selectedColor!) : ""
            
            if colorString == selectedColorString {
                cell.changeSelection(true)
                selectedColorIndexPath = indexPath
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            } else {
                cell.changeSelection(false)
            }
            
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
        
        header.titleLabel.text = indexPath.section == 0 ? "Emoji" : "Цвет"
        
        return header
    }
}
