import Foundation

final class TrackerViewModel{
    private let categoryDataProvider: TrackerCategoryDataProviderProtocol
    
    var onCategorySelected: ((String) -> Void)?
    var onCategoriesUpdated: ((TrackerCategoryStoreUpdate) -> Void)?
    
    private(set) var selectedCategoryName: String?
    var categoriesCount: Int {
        categoryDataProvider.numberOfItemsInSection(0)
    }
    
    init(dataProvider: TrackerCategoryDataProviderProtocol, selectedCategoryName: String?) {
        self.categoryDataProvider = dataProvider
        self.selectedCategoryName = selectedCategoryName
        self.categoryDataProvider.delegate = self
    }
    
    // MARK: - Methods
    func isCategorySelected(at indexPath: IndexPath) -> Bool {
        let name = categoryDataProvider.getCategoryName(at: indexPath)
        return name == selectedCategoryName
    }
    
    func selectCategory(at indexPath: IndexPath) {
        guard let name = categoryDataProvider.getCategoryName(at: indexPath) else { return }
        selectedCategoryName = name
        onCategorySelected?(name)
    }
    
    func categoryName(at indexPath: IndexPath) -> String? {
        categoryDataProvider.getCategoryName(at: indexPath)
    }
    
    func deleteCategory(at indexPath: IndexPath) {
        guard let name = categoryName(at: indexPath) else { return }
        categoryDataProvider.deleteCategory(with: name)
    }
    
    func addCategory(name: String) {
        categoryDataProvider.addNewCategory(trackerCategory: TrackerCategory(name: name, trackers: []))
    }
    
    func updateCategoryName(oldName: String, newName: String){
        categoryDataProvider.updateCategoryName(oldName: oldName, newName: newName)
    }
}

// MARK: - TrackerCategoryDataProviderDelegate
extension TrackerViewModel: TrackerCategoryDataProviderDelegate {
    func didUpdate(_ update: TrackerCategoryStoreUpdate) {
        onCategoriesUpdated?(update)
    }
}
