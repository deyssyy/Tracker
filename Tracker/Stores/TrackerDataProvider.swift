import Foundation
import CoreData

protocol TrackerDataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

struct TrackerStoreUpdate {
    let insertedIndexPaths: [IndexPath]
    let deletedIndexPaths: [IndexPath]
    let updatedIndexPaths: [IndexPath]
    let insertedSections: IndexSet
    let deletedSections: IndexSet
}

protocol TrackerDataProviderProtocol: AnyObject {
    var isItemsEmpty: Bool { get }
    var numberOfSections: Int { get }
    func numberOfItemsInSection(_ section: Int) -> Int
    func fetchTracker(at indexPath: IndexPath) -> Tracker?
    func fetchSectionName(at section: Int) -> String?
    
    func addTracker(_ tracker: Tracker, to categoryName: String)
    func deleteTracker(at indexPath: IndexPath)
    func updateTracker(_ tracker: Tracker, at indexPath: IndexPath, to categoryName: String)
    func updateFilters(for date: Date)
    func togglePin(forTrackerAt indexPath: IndexPath)
    
    func getTrackerCoreData(at indexPath: IndexPath) -> TrackerCoreData
    func checkIsCompleted(_ trackerId: UUID, date: Date) -> Bool
    func countOfCompletedDays(_ trackerId: UUID) -> Int
}

final class TrackerDataProvider: NSObject, TrackerDataProviderProtocol {
    
    weak var delegate: TrackerDataProviderDelegate?
    
    private let context: NSManagedObjectContext
    private let trackerStore: TrackerStore
    private let uiColorMarshalling = UIColorMarshalling()
    
    private var insertedIndexPaths: [IndexPath] = []
    private var deletedIndexPaths: [IndexPath] = []
    private var updatedIndexPaths: [IndexPath] = []
    private var insertedSections: IndexSet = []
    private var deletedSections: IndexSet = []
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.isPinned, ascending: false),
            NSSortDescriptor(keyPath: \TrackerCoreData.category?.name, ascending: true),
            NSSortDescriptor(keyPath: \TrackerCoreData.title, ascending: true)
        ]
        
        let currentDay = Calendar.current.component(.weekday, from: Date())
        fetchRequest.predicate = NSPredicate(format: "days CONTAINS %@", String(currentDay))
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(TrackerCoreData.sectionName),
            cacheName: nil
        )
        
        controller.delegate = self
        
        do {
            try controller.performFetch()
        } catch {
            print("Failed to fetch trackers: \(error)")
        }
        
        return controller
    }()
    
    init(dataStore: TrackerStore, delegate: TrackerDataProviderDelegate ) {
        context = CoreDataStack.shared.context
        self.trackerStore = dataStore
        self.delegate = delegate
    }
    
    // MARK: - Внешние методы для UI
    
    var isItemsEmpty: Bool {
        fetchedResultsController.fetchedObjects?.isEmpty ?? true
    }
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func fetchTracker(at indexPath: IndexPath) -> Tracker? {
        let trackerCoreData =  fetchedResultsController.object(at: indexPath)
        guard
            let id = trackerCoreData.id,
            let title = trackerCoreData.title,
            let emoji = trackerCoreData.emoji,
            let colorString = trackerCoreData.color,
            let rawDays = trackerCoreData.days
        else { return nil }
        let color = uiColorMarshalling.deserialize(colorString)
        let days = rawDays
            .components(separatedBy: ",")
            .compactMap { Int($0) }
            .compactMap { DayOfWeek(rawValue: $0) }
        
        return Tracker(
            id: id,
            title: title,
            color: color,
            emoji: emoji,
            days: days,
            isPinned: trackerCoreData.isPinned
        )
    }
    
    func addTracker(_ tracker: Tracker, to categoryName: String) {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", categoryName)
        
        do {
            let results = try context.fetch(request)
            let categoryCoreData: TrackerCategoryCoreData
            
            if let foundCategory = results.first {
                categoryCoreData = foundCategory
            } else {
                categoryCoreData = TrackerCategoryCoreData(context: context)
                categoryCoreData.name = categoryName
            }
            
            trackerStore.addNewTracker(tracker, trackerCategory: categoryCoreData)
            
        } catch {
            print("Error fetching/creating category: \(error)")
        }
    }
    
    func deleteTracker(at indexPath: IndexPath){
        let trackerToDelete = fetchedResultsController.object(at: indexPath)
        
        trackerStore.deleteTracker(trackerToDelete)
    }
    
    func updateTracker(_ tracker: Tracker, at indexPath: IndexPath, to categoryName: String) {
        let trackerCoreData = getTrackerCoreData(at: indexPath)
        
        let categoryRequest = TrackerCategoryCoreData.fetchRequest()
        categoryRequest.predicate = NSPredicate(format: "name == %@", categoryName)
        
        guard let categories = try? context.fetch(categoryRequest),
              let categoryCoreData = categories.first else { return }
        
        trackerStore.updateTracker(tracker: tracker, trackerCoreData: trackerCoreData, category: categoryCoreData)
        trackerStore.deleteInvalidRecords(for: tracker.id, newSchedule: tracker.days)
    }
    
    func togglePin(forTrackerAt indexPath: IndexPath) {
        let trackerCoreData = getTrackerCoreData(at: indexPath)
        trackerStore.togglePin(for: trackerCoreData)
    }
    
    func fetchSectionName(at section: Int) -> String? {
        fetchedResultsController.sections?[section].name
    }
    
    func updateFilters(for date: Date) {
        let dayNumber = Calendar.current.component(.weekday, from: date)
        fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "days CONTAINS %@", String(dayNumber))
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Fetch error: \(error)")
        }
    }
    
    func getTrackerCoreData(at indexPath: IndexPath) -> TrackerCoreData {
        let trackerCoreData =  fetchedResultsController.object(at: indexPath)
        return trackerCoreData
    }
    
    func checkIsCompleted(_ trackerId: UUID, date: Date) -> Bool{
        let request = TrackerRecordCoreData.fetchRequest()
        
        let cleanDate = Calendar.current.startOfDay(for: date)
        
        request.predicate = NSPredicate(format: "tracker.id == %@ AND %K == %@", trackerId as CVarArg, #keyPath(TrackerRecordCoreData.date), cleanDate as NSDate)
        
        request.fetchLimit = 1
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            return false
        }
    }
    
    func countOfCompletedDays(_ trackerId: UUID) -> Int {
        let request = TrackerRecordCoreData.fetchRequest()
        
        request.predicate = NSPredicate(format: "tracker.id == %@", trackerId as CVarArg)
        
        do{
            let count = try context.count(for: request)
            return count
        }catch{
            return 0
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerDataProvider: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths.removeAll()
        deletedIndexPaths.removeAll()
        updatedIndexPaths.removeAll()
        insertedSections.removeAll()
        deletedSections.removeAll()
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
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: insertedSections.insert(sectionIndex)
        case .delete: deletedSections.insert(sectionIndex)
        default: break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let update = TrackerStoreUpdate(
            insertedIndexPaths: insertedIndexPaths,
            deletedIndexPaths: deletedIndexPaths,
            updatedIndexPaths: updatedIndexPaths,
            insertedSections: insertedSections,
            deletedSections: deletedSections
        )
        delegate?.didUpdate(update)
    }
}

extension TrackerCoreData {
    @objc var sectionName: String? {
        return isPinned ? "Закрепленные" : category?.name
    }
}
