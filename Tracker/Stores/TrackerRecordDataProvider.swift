import Foundation
import CoreData

protocol TrackerRecordDataProviderDelegate: AnyObject {
    func didUpdateRecord(for trackerId: UUID)
}

protocol TrackerRecordDataProviderProtocol: AnyObject {
    func checkIsCompleted(_ trackerId: UUID, date: Date) -> Bool
    func countOfCompletedDays(_ trackerId: UUID) -> Int
    func addTrackerRecord(_ record: TrackerRecord, trackerCoreData: TrackerCoreData)
    func deleteTrackerRecord(trackerId: UUID, date: Date)
}

final class TrackerRecordDataProvider: NSObject, TrackerRecordDataProviderProtocol{
    weak var delegate: TrackerRecordDataProviderDelegate?
    
    private let context: NSManagedObjectContext
    private let trackerRecordStore: TrackerRecordStore
    
    private let fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>
    
    init(dataStore: TrackerRecordStore, delegate: TrackerRecordDataProviderDelegate) {
        context = CoreDataStack.shared.context
        self.trackerRecordStore = dataStore
        self.delegate = delegate
        
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        self.fetchedResultsController = controller
        
        super.init()
        
        controller.delegate = self
        try? controller.performFetch()
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
    
    func countOfCompletedDays(_ trackerId: UUID) -> Int {
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
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let record = anObject as? TrackerRecordCoreData,
              let trackerId = record.tracker?.id else { return }
        
        delegate?.didUpdateRecord(for: trackerId)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
}
