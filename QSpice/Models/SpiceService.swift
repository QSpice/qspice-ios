import CoreData

class SpiceService {
    
    private(set) var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func countForSpices() throws -> Int {
        return try context.count(for: Spice.fetchRequest())
    }
    
    func addSpice(name: String, weight: Float, color: String) {
        let spice = NSEntityDescription.insertNewObject(forEntityName: "Spice", into: context)
        spice.setValue(name, forKey: "name")
        spice.setValue(weight, forKey: "weight")
        spice.setValue(color, forKey: "color")
    }
    
    func activeSpice(for slot: Int) throws -> Spice? {
        let request: NSFetchRequest<Spice> = Spice.fetchRequest()
        request.predicate = NSPredicate(format: "slot == %d", slot)
        
        let spices = try context.fetch(request)
        
        return spices.first
    }
    
    func activeSpices() throws -> [Spice] {
        let request: NSFetchRequest<Spice> = Spice.fetchRequest()
        request.predicate = NSPredicate(format: "active == 1")
        
        return try context.fetch(request)
    }
    
    func save() throws {
        try context.save()
    }
    
}
