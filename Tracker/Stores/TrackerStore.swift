import CoreData

final class TrackerStore{
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    
    convenience init() {
        let context = CoreDataStack.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addNewTracker(_ tracker: Tracker, trackerCategory: TrackerCategoryCoreData) {
        let color = uiColorMarshalling.serialize(tracker.color)
        let trackerCoreData = TrackerCoreData(context: context)
        
        trackerCoreData.id = tracker.id
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.title = tracker.title
        trackerCoreData.color = color
        trackerCoreData.days = tracker.days.map { String($0.rawValue) }.joined(separator: ",")
        trackerCoreData.isPinned = tracker.isPinned
        
        trackerCoreData.category = trackerCategory
        
        CoreDataStack.shared.saveContext()
    }
    
    func deleteTracker(_ tracker: TrackerCoreData) {
        context.delete(tracker)
        CoreDataStack.shared.saveContext()
    }
    
    func updateTracker(tracker: Tracker, trackerCoreData: TrackerCoreData, category: TrackerCategoryCoreData){
        let color = uiColorMarshalling.serialize(tracker.color)
        
        trackerCoreData.title = tracker.title
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = color
        trackerCoreData.days = tracker.days.map { String($0.rawValue) }.joined(separator: ",")
        trackerCoreData.isPinned = tracker.isPinned
        
        trackerCoreData.category = category
        
        CoreDataStack.shared.saveContext()
    }
    
    func deleteInvalidRecords(for trackerId: UUID, newSchedule: [DayOfWeek]) {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "tracker.id == %@", trackerId as CVarArg)
        
        do {
            let records = try context.fetch(request)
            for record in records {
                guard let date = record.date else { continue }
                let weekday = Calendar.current.component(.weekday, from: date)
                
                if !newSchedule.contains(where: { $0.rawValue == weekday }) {
                    context.delete(record)
                }
            }
            CoreDataStack.shared.saveContext()
        } catch {
            print("Ошибка очистки записей: \(error)")
        }
    }
    
    func togglePin(for trackerCoreData: TrackerCoreData) {
        trackerCoreData.isPinned.toggle()
        CoreDataStack.shared.saveContext()
    }
}
