import UIKit
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
        
        trackerCoreData.category = trackerCategory
        
        CoreDataStack.shared.saveContext()
    }
}
