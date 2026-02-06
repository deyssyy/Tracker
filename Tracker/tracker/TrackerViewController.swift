import UIKit

struct GeometricParams {
    let cellCount: Int
    let leftInset: CGFloat
    let rightInset: CGFloat
    let cellSpacing: CGFloat
    let paddingWidth: CGFloat
    
    init(cellCount: Int, leftInset: CGFloat, rightInset: CGFloat, cellSpacing: CGFloat) {
        self.cellCount = cellCount
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.cellSpacing = cellSpacing
        self.paddingWidth = leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacing
    }
}

final class TrackerViewController: UIViewController{
    private let headerLabel = UILabel()
    private let newTrackerButton = UIButton()
    private let datePicker = UIDatePicker()
    private let searchBar = UISearchBar()
    private let defaultImage = UIImageView()
    private let defaultLabel = UILabel()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let filterButton = UIButton()
    private let params = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)
    
    private var trackerDataProvider: TrackerDataProviderProtocol?
    private var trackerRecordDataProvider: TrackerRecordDataProviderProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        let trackerStore = TrackerStore()
        trackerDataProvider = TrackerDataProvider(dataStore: trackerStore, delegate: self)
        let trackerRecordStore = TrackerRecordStore()
        trackerRecordDataProvider = TrackerRecordDataProvider(dataStore: trackerRecordStore, delegate: self)
        showPlaceholder()
    }
    
    //MARK: UI SETUP METHODS
    private func setupUI() {
        setupNewTrackerButton()
        setupHeaderLabel()
        setupDatePicker()
        setupSearchBar()
        setupCollectionView()
        setupDefaultImageAndLabel()
        setupFilterButton()
    }
    
    private func setupFilterButton(){
        filterButton.setTitle("Фильтры", for: .normal)
        filterButton.layer.cornerRadius = 16
        filterButton.backgroundColor = .ypBlue
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterButton)
        
        NSLayoutConstraint.activate([
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114)
        ])
    }
    
    private func setupCollectionView(){
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier)
        collectionView.register(
            TrackerHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerHeaderView.identifier
        )
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupHeaderLabel(){
        headerLabel.text = "Трекеры"
        headerLabel.font = UIFont.boldSystemFont(ofSize: 34)
        headerLabel.textColor = .blackDay
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: newTrackerButton.bottomAnchor, constant: 1),
            headerLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 105)
        ])
    }
    
    private func setupNewTrackerButton(){
        newTrackerButton.setImage(UIImage(resource: .addTracker), for: .normal)
        newTrackerButton.addTarget(
            self,
            action: #selector(addNewTask),
            for: .touchUpInside)
        newTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newTrackerButton)
        
        NSLayoutConstraint.activate([
            newTrackerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: 6),
            newTrackerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 1),
            newTrackerButton.widthAnchor.constraint(equalToConstant: 42),
            newTrackerButton.heightAnchor.constraint(equalToConstant: 42)
        ])
    }
    
    private func setupDatePicker(){
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(dateChange), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.centerYAnchor.constraint(equalTo: newTrackerButton.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupSearchBar(){
        searchBar.placeholder = "Поиск"
        searchBar.backgroundImage = UIImage()
        searchBar.layoutMargins = UIEdgeInsets.zero
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor, constant: -8),
            searchBar.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 7),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8)
        ])
    }
    
    private func setupDefaultImageAndLabel(){
        defaultImage.image = UIImage(resource: .noTask)
        defaultLabel.text = "Что будем отслеживать?"
        defaultLabel.font = UIFont.systemFont(ofSize: 12)
        defaultLabel.textColor = .blackDay
        defaultLabel.textAlignment = .center
        defaultImage.translatesAutoresizingMaskIntoConstraints = false
        defaultLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(defaultImage)
        view.addSubview(defaultLabel)
        
        NSLayoutConstraint.activate([
            defaultImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            defaultImage.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -330),
            defaultImage.widthAnchor.constraint(equalToConstant: 80),
            defaultImage.heightAnchor.constraint(equalToConstant: 80),
            defaultLabel.topAnchor.constraint(equalTo: defaultImage.bottomAnchor, constant: 8),
            defaultLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            defaultLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    //MARK: SUPPORT METHODS
    private func showPlaceholder(){
        guard let isEmpty = trackerDataProvider?.isItemsEmpty else { return }
        
        defaultImage.isHidden = !isEmpty
        defaultLabel.isHidden = !isEmpty
        filterButton.isHidden = isEmpty
    }
    
    private func selectedDateIsFuture() -> Bool{
        return Calendar.current.startOfDay(for: datePicker.date) > Date()
    }
    //MARK: BUTTONS ATIONS
    @objc private func addNewTask(){
        let newTrackeVc = NewTrackerViewController()
        newTrackeVc.delegate = self
        let navigationVC = UINavigationController(rootViewController: newTrackeVc)
        navigationVC.modalPresentationStyle = .popover
        present(navigationVC, animated: true)
    }
    
    @objc private func dateChange(_ sender: UIDatePicker){
        trackerDataProvider?.updateFilters(for: sender.date)
        UIView.transition(with: collectionView, duration: 0.35, options: .transitionCrossDissolve, animations: {
            self.collectionView.reloadData()
        }, completion: nil)
        showPlaceholder()
    }
}
//MARK: UICollectionViewDelegateFlowLayout
extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: params.leftInset, bottom: 12, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 46)
    }
}
//MARK: UICollectionViewDataSource
extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return trackerDataProvider?.numberOfSections ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trackerDataProvider?.numberOfItemsInSection(section) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier, for: indexPath) as? TrackerCollectionViewCell,
            let tracker = trackerDataProvider?.fetchTracker(at: indexPath)
        else {
            return UICollectionViewCell()
        }
        
        guard let isCompleted = trackerRecordDataProvider?.checkIsCompleted(tracker.id, date: datePicker.date),
              let complitionCount = trackerRecordDataProvider?.countOfcompletedDays(tracker.id)
        else { return UICollectionViewCell() }
        let isFutureDate = selectedDateIsFuture()
        
        cell.delegate = self
        cell.configure(tracker: tracker, isCompleted: isCompleted, completionCount: complitionCount, isFuture: isFutureDate)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerHeaderView.identifier,
            for: indexPath
        ) as? TrackerHeaderView else {
            return UICollectionReusableView()
        }
        
        let sectionTitle = trackerDataProvider?.fetchSectionName(at: indexPath.section)
        header.titleLabel.text = sectionTitle
        return header
    }
}

extension TrackerViewController: NewTrackerViewControllerDelegate{
    func didCreateNewTracker(_ tracker: Tracker, for categoryName: String) {
        trackerDataProvider?.addTracker(tracker, to: categoryName)
    }
}

extension TrackerViewController: TrackerDataProviderDelegate{
    func didUpdate(_ update: TrackerStoreUpdate) {
        collectionView.performBatchUpdates {
            collectionView.insertSections(update.insertedSections)
            collectionView.deleteSections(update.deletedSections)
            
            collectionView.insertItems(at: update.insertedIndexPaths)
            collectionView.deleteItems(at: update.deletedIndexPaths)
            collectionView.reloadItems(at: update.updatedIndexPaths)
        } completion: { _ in
            self.showPlaceholder()
        }
    }
}

extension TrackerViewController: TrackerRecordDataProviderDelegate{
    func didUpdate(_ update: TrackerRecordUpdate) {
        collectionView.reloadData()
    }
}

extension TrackerViewController: TrackerCollectionViewCellProtocol{
    func increaceDaysCount(in cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        guard let trackerCoreData = trackerDataProvider?.getTrackerCoreData(at: indexPath) else { return }
        guard let id = trackerCoreData.id else {
            return
        }
        let cleanDate = Calendar.current.startOfDay(for: datePicker.date)
        
        trackerRecordDataProvider?.addTrackerRecord(
            TrackerRecord(id: id, date: cleanDate), trackerCoreData: trackerCoreData)
    }
    
    func decreaceDaysCount(in cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        guard let trackerCoreData = trackerDataProvider?.getTrackerCoreData(at: indexPath) else { return }
        guard let id = trackerCoreData.id else {
            return
        }
        let cleanDate = Calendar.current.startOfDay(for: datePicker.date)
        
        trackerRecordDataProvider?.deleteTrackerRecord(trackerId: id, date: cleanDate)
    }
}
