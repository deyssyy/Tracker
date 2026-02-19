import Foundation
import CoreData

protocol TrackerCategoryDataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackerCategoryStoreUpdate)
}

protocol TrackerCategoryDataProviderProtocol: AnyObject{
    var delegate: TrackerCategoryDataProviderDelegate? { get set } 
    var isItemsEmpty: Bool { get }
    
    func numberOfItemsInSection(_ section: Int) -> Int
    func getCategoryName(at indexPath: IndexPath) -> String?
    
    func addNewCategory(trackerCategory: TrackerCategory)
    func deleteCategory(with name: String)
    func updateCategoryName(oldName: String, newName: String)
}

struct TrackerCategoryStoreUpdate {
    let insertedIndexPaths: [IndexPath]
    let deletedIndexPaths: [IndexPath]
    let updatedIndexPaths: [IndexPath]
}

final class TrackerCategoryDataProvider: NSObject, TrackerCategoryDataProviderProtocol{
    private let context: NSManagedObjectContext
    private let trackerCategoryStore: TrackerCategoryStore
    
    weak var delegate: TrackerCategoryDataProviderDelegate?
    
    private var insertedIndexPaths: [IndexPath] = []
    private var deletedIndexPaths: [IndexPath] = []
    private var updatedIndexPaths: [IndexPath] = []
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.name, ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller.delegate = self
        
        do {
            try controller.performFetch()
        } catch {
            print("Failed to fetch categories: \(error)")
        }
        
        return controller
    }()
    
    init(dataStore: TrackerCategoryStore) {
        self.context = CoreDataStack.shared.context
        self.trackerCategoryStore = dataStore
        super.init()
    }
    
    var isItemsEmpty: Bool {
        fetchedResultsController.fetchedObjects?.isEmpty ?? true
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func getCategoryName(at indexPath: IndexPath) -> String? {
        let categoryCoreData = fetchedResultsController.object(at: indexPath)
        return categoryCoreData.name
    }
    
    func addNewCategory(trackerCategory: TrackerCategory){
        trackerCategoryStore.addNewCategory(category: trackerCategory)
    }
    
    func deleteCategory(with name: String){
        trackerCategoryStore.deleteCategory(with: name)
    }
    
    func updateCategoryName(oldName: String, newName: String){
        trackerCategoryStore.updateCategoryName(oldName: oldName, newName: newName)
    }
}

extension TrackerCategoryDataProvider: NSFetchedResultsControllerDelegate{
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths.removeAll()
        deletedIndexPaths.removeAll()
        updatedIndexPaths.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath { insertedIndexPaths.append(indexPath) }
        case .delete:
            if let indexPath = indexPath { deletedIndexPaths.append(indexPath) }
        case .update:
            if let indexPath = indexPath { updatedIndexPaths.append(indexPath) }
        case .move:
            if let old = indexPath, let new = newIndexPath {
                deletedIndexPaths.append(old)
                insertedIndexPaths.append(new)
            }
        @unknown default: break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let update = TrackerCategoryStoreUpdate(
            insertedIndexPaths: insertedIndexPaths,
            deletedIndexPaths: deletedIndexPaths,
            updatedIndexPaths: updatedIndexPaths)
        delegate?.didUpdate(update)
    }
}
