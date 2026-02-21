import CoreData

final class TrackerCategoryStore{
    private let context: NSManagedObjectContext
    
    convenience init() {
        let context = CoreDataStack.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addNewCategory(category: TrackerCategory){
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "name ==[c] %@", category.name)
        
        do {
            let existingCategories = try context.fetch(fetchRequest)
            
            if !existingCategories.isEmpty {
                print("Категория с именем '\(category.name)' уже существует")
                return
            }
            
            let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
            
            trackerCategoryCoreData.name = category.name
            
            CoreDataStack.shared.saveContext()
            
        } catch {
            print("Ошибка при проверке категории: \(error)")
        }
    }
    
    
    func deleteCategory(with name: String){
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "name = %@", name)
        request.fetchLimit = 1
        
        do {
            if let categoryToDelete = try context.fetch(request).first {
                context.delete(categoryToDelete)
                CoreDataStack.shared.saveContext()
            }
        } catch {
            print("Failed to delete record: \(error)")
        }
    }
    
    func updateCategoryName(oldName: String, newName: String){
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "name = %@", oldName)
        request.fetchLimit = 1
        
        do {
            if let categoryToUpdate = try context.fetch(request).first {
                categoryToUpdate.name = newName
                CoreDataStack.shared.saveContext()
            }
        } catch {
            print("Failed to update record: \(error)")
        }
    }
}
