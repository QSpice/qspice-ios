import Foundation
import CoreData

public class CoreDataManager {
    public static var shared = CoreDataManager()
    
    private init() {
        
    }
    
    private lazy var persistentContainer: SharedPersistentContainer = {
        let container = SharedPersistentContainer(name: "QSpice")
        container.loadPersistentStores(completionHandler: { [weak self] (_, error) in
            if let error = error {
                print(error.localizedDescription)
            }
        })
        return container
    }()
    
    public var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    public func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
            }
        }
    }
}
