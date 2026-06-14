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
    
    private var selectedFilter: FilterType = .all
    private var trackerDataProvider: TrackerDataProviderProtocol?
    private var trackerRecordDataProvider: TrackerRecordDataProviderProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        let statisticDataProvider = StatisticsDataProvider(context: CoreDataStack.shared.context)
        let trackerStore = TrackerStore()
        trackerDataProvider = TrackerDataProvider(dataStore: trackerStore, delegate: self,statisticsDataProvider: statisticDataProvider)
        let trackerRecordStore = TrackerRecordStore()
        trackerRecordDataProvider = TrackerRecordDataProvider(dataStore: trackerRecordStore, delegate: self,statisticsDataProvider: statisticDataProvider)
        let savedRawValue = UserDefaults.standard.integer(forKey: "selectedFilter")
            self.selectedFilter = FilterType(rawValue: savedRawValue) ?? .all
            
            // Применяем фильтр сразу при старте
            trackerDataProvider?.updateFilters(
                for: datePicker.date,
                searchText: nil,
                filter: selectedFilter
            )
        showPlaceholder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.reportOpen()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.reportClose()
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
        view.backgroundColor = .whiteNight
    }
    
    private func setupFilterButton(){
        filterButton.setTitle("filter_button_title".localized, for: .normal)
        filterButton.addTarget(
            self,
            action: #selector(filterButtonDidTap),
            for: .touchUpInside)
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
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        collectionView.scrollIndicatorInsets = collectionView.contentInset
        collectionView.backgroundColor = .whiteNight
        
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
        headerLabel.text = "main_screen_header_label".localized
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
        datePicker.calendar = .current
        datePicker.addTarget(self, action: #selector(dateChange), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.centerYAnchor.constraint(equalTo: newTrackerButton.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupSearchBar(){
        searchBar.placeholder = "search_bar_placeholder".localized
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.clearButtonMode = .never
        searchBar.layoutMargins = UIEdgeInsets.zero
        searchBar.delegate = self
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
        defaultLabel.text = "default_label".localized
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
        
        guard let hasAnyTrackers = trackerDataProvider?.isSelectedDayEmpty(date: datePicker.date) else { return }
        
        let isSearch = !(searchBar.text?.isEmpty ?? true)
        
        defaultImage.isHidden = !isEmpty
        defaultLabel.isHidden = !isEmpty
        filterButton.isHidden = !hasAnyTrackers
        
        if isSearch || selectedFilter == .completed || selectedFilter == .uncompleted{
            defaultImage.image = UIImage(resource: .searchDefault)
            defaultLabel.text = "search_default_label".localized
        } else {
            defaultImage.image = UIImage(resource: .noTask)
            defaultLabel.text = "default_label".localized
        }
    }
    
    private func selectedDateIsFuture() -> Bool{
        return Calendar.current.startOfDay(for: datePicker.date) > Date()
    }
    //MARK: BUTTONS ATIONS
    @objc private func addNewTask(){
        AnalyticsService.reportClick(.addTrack)
        let newTrackerVc = NewTrackerViewController()
        newTrackerVc.delegate = self
        let navigationVC = UINavigationController(rootViewController: newTrackerVc)
        navigationVC.modalPresentationStyle = .popover
        navigationVC.presentationController?.delegate = newTrackerVc
        present(navigationVC, animated: true)
    }
    
    @objc private func dateChange(_ sender: UIDatePicker){
        if selectedFilter == .today {
                selectedFilter = .all
                UserDefaults.standard.set(FilterType.all.rawValue, forKey: "selectedFilter")
            }
        let currentSearchText = searchBar.text
        trackerDataProvider?.updateFilters(for: sender.date, searchText: currentSearchText, filter: selectedFilter)
        UIView.transition(with: collectionView, duration: 0.35, options: .transitionCrossDissolve, animations: {
            self.collectionView.reloadData()
        }, completion: nil)
        showPlaceholder()
    }
    
    @objc private func filterButtonDidTap(){
        AnalyticsService.reportClick(.filter)
        let filterVc = FilterViewController(currentFilter: selectedFilter)
        filterVc.delegate = self
        let navigationVC = UINavigationController(rootViewController: filterVc)
        navigationVC.modalPresentationStyle = .popover
        present(navigationVC, animated: true)
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
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first else { return nil }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) {[weak self] _ in
            let tracker = self?.trackerDataProvider?.fetchTracker(at: indexPath)
            let pinAction = UIAction(title: tracker?.isPinned == true ? "pin_tracker_action_title_off".localized : "pin_tracker_action_title_on".localized){ [weak self] _ in
                guard let self = self else { return }
                
                self.trackerDataProvider?.togglePin(forTrackerAt: indexPath)
            }
            let editAction = UIAction(title: "edit_tracker_action_title".localized){ _ in
                AnalyticsService.reportClick(.edit)
                guard let self = self,
                      let tracker = self.trackerDataProvider?.fetchTracker(at: indexPath),
                      let completedDays = self.trackerDataProvider?.countOfCompletedDays(tracker.id),
                      let categoryName = self.trackerDataProvider?.fetchSectionName(at: indexPath.section) else { return }
                let editVC = NewTrackerViewController(mode: .edit(
                    tracker: tracker,
                    categoryName: categoryName,
                    completedDays: completedDays,
                    indexPath: indexPath
                ))
                
                editVC.delegate = self
                
                let navController = UINavigationController(rootViewController: editVC)
                navController.modalPresentationStyle = .popover
                self.present(navController, animated: true)
            }
            let deleteAction = UIAction(title: "delete_tracker_action_title".localized,attributes: .destructive){ _ in
                AnalyticsService.reportClick(.delete)
                self?.trackerDataProvider?.deleteTracker(at: indexPath)
            }
            return UIMenu(children: [pinAction, editAction, deleteAction])
        }
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
              let complitionCount = trackerRecordDataProvider?.countOfCompletedDays(tracker.id)
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
    func didUpdateTracker(tracker: Tracker, for categoryName: String, indexPath: IndexPath) {
        trackerDataProvider?.updateTracker(tracker, at: indexPath, to: categoryName)
    }
    
    func didCloseWithNoNewTracker() {
        trackerDataProvider?.updateFilters(for: datePicker.date, searchText: nil, filter: selectedFilter)
        collectionView.reloadData()
    }
    
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
    func didUpdateRecord(for trackerId: UUID) {
        let visiblePaths = collectionView.indexPathsForVisibleItems
        if let pathUpdate = visiblePaths.first(where: {
            trackerDataProvider?.getTrackerCoreData(at: $0).id == trackerId
        }) {
            collectionView.reloadItems(at: [pathUpdate])
        }
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

extension TrackerViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        trackerDataProvider?.updateFilters(for: datePicker.date, searchText: searchText, filter: selectedFilter)
        UIView.transition(with: collectionView, duration: 0.35, options: .transitionCrossDissolve, animations: {
            self.collectionView.reloadData()
        }, completion: nil)
        showPlaceholder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
}

extension TrackerViewController: FilterViewControllerDelegate{
    func didUpdateFilter(filter: FilterType) {
        self.selectedFilter = filter
        var currentDate = datePicker.date
        UserDefaults.standard.set(filter.rawValue, forKey: "selectedFilter")
        
        if filter == .today {
            self.datePicker.setDate(Date(), animated: true)
            currentDate = Date()
        }
        
        trackerDataProvider?.updateFilters(
            for: currentDate,
            searchText: searchBar.text,
            filter: filter
        )
        UIView.transition(with: collectionView, duration: 0.35, options: .transitionCrossDissolve, animations: {
            self.collectionView.reloadData()
        }, completion: nil)
        showPlaceholder()
    }
}
