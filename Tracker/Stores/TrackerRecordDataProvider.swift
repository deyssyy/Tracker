import Foundation
import CoreData

protocol TrackerRecordDataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackerRecordUpdate)
}

struct TrackerRecordUpdate{
    let insertedIndexPaths: [IndexPath]
    let deletedIndexPaths: [IndexPath]
    let updatedIndexPaths: [IndexPath]
}

protocol TrackerRecordDataProviderProtocol: AnyObject {
    func checkIsCompleted(_ trackerId: UUID, date: Date) -> Bool
    func countOfcompletedDays(_ trackerId: UUID) -> Int
    func addTrackerRecord(_ record: TrackerRecord, trackerCoreData: TrackerCoreData)
    func deleteTrackerRecord(trackerId: UUID, date: Date)
}

final class TrackerRecordDataProvider: NSObject, TrackerRecordDataProviderProtocol{
    weak var delegate: TrackerRecordDataProviderDelegate?
    
    private let context: NSManagedObjectContext
    private let trackerRecordStore: TrackerRecordStore
    
    private var insertedIndexPaths: [IndexPath] = []
    private var deletedIndexPaths: [IndexPath] = []
    private var updatedIndexPaths: [IndexPath] = []
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: true),
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
            print("Failed to fetch trackers: \(error)")
        }
        
        return controller
    }()
    
    init(dataStore: TrackerRecordStore, delegate: TrackerRecordDataProviderDelegate) {
        context = CoreDataStack.shared.context
        self.trackerRecordStore = dataStore
        self.delegate = delegate
    }
    
    func checkIsCompleted(_ trackerId: UUID, date: Date) -> Bool {
        let request = TrackerRecordCoreData.fetchRequest()
        let cleanDate = Calendar.current.startOfDay(for: date)
        
        request.predicate = NSPredicate(
            format: "tracker.id == %@ AND %K == %@",
            trackerId as CVarArg,
            #keyPath(TrackerRecordCoreData.date),
            cleanDate as NSDate
        )
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            return false
        }
    }
    
    func countOfcompletedDays(_ trackerId: UUID) -> Int {
        let request = TrackerRecordCoreData.fetchRequest()
        
        request.predicate = NSPredicate(format: "tracker.id == %@", trackerId as CVarArg)
        
        do {
            let count = try context.count(for: request)
            return count
        } catch {
            return 0
        }
    }
    
    
    func addTrackerRecord(_ record: TrackerRecord, trackerCoreData: TrackerCoreData){
        trackerRecordStore.addNewRecord(record, trackerCoreData: trackerCoreData)
    }
    
    func deleteTrackerRecord(trackerId: UUID, date: Date) {
        trackerRecordStore.deleteRecord(trackerId: trackerId, date: date)
    }
}

extension TrackerRecordDataProvider: NSFetchedResultsControllerDelegate{
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
        let update = TrackerRecordUpdate(
            insertedIndexPaths: insertedIndexPaths,
            deletedIndexPaths: deletedIndexPaths,
            updatedIndexPaths: updatedIndexPaths
        )
        delegate?.didUpdate(update)
    }
}
