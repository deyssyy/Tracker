import UIKit
import CoreData

final class TrackerRecordStore{
    private let context: NSManagedObjectContext
    
    convenience init() {
        let context = CoreDataStack.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addNewRecord(_ record: TrackerRecord, trackerCoreData: TrackerCoreData) {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        
        trackerRecordCoreData.id = record.id
        trackerRecordCoreData.date = record.date
        
        trackerRecordCoreData.tracker = trackerCoreData
        
        CoreDataStack.shared.saveContext()
    }
    
    func deleteRecord(trackerId: UUID, date: Date){
        let request = TrackerRecordCoreData.fetchRequest()
        let cleanDate = Calendar.current.startOfDay(for: date)
        
        request.predicate = NSPredicate(
            format: "tracker.id == %@ AND %K == %@",
            trackerId as CVarArg,
            #keyPath(TrackerRecordCoreData.date),
            cleanDate as NSDate
        )
        
        do {
            let records = try context.fetch(request)
            guard let recordToDelete = records.first else { return }
            context.delete(recordToDelete)
            CoreDataStack.shared.saveContext()
        } catch {
            print("Failed to delete record: \(error)")
        }
    }
}
