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
        
        let sort = NSSortDescriptor(key: "slot", ascending: true)
        request.sortDescriptors = [sort]
        
        return try context.fetch(request)
    }
    
    func createListOrder(orderDetail: OrderDetail) {
        let order = Order(context: context)
        
        order.date = Date()
        order.quantity = Int32(orderDetail.quantity)
        
        for item in orderDetail.orderItems where item.ingredient.amount > 0.0 {
            let orderItem = OrderItem(context: context)
            
            let ingredient = Ingredient(context: context)
            ingredient.amount = item.ingredient.amount
            ingredient.metric = item.ingredient.metric
            ingredient.spice = item.ingredient.spice
            
            orderItem.ingredient = ingredient
            order.addToOrderItems(orderItem)
        }
        
    }
    
    func createRecipeOrder(orderDetail: OrderDetail) {
        guard let recipe = orderDetail.recipe else {
            return
        }
        
        let order = Order(context: context)
        
        order.date = Date()
        order.quantity = Int32(orderDetail.quantity)
        order.recipe = recipe
        
        for ingredient in recipe.ingredients?.allObjects as? [Ingredient] ?? [] {
            let orderItem = OrderItem(context: context)
            
            orderItem.ingredient = ingredient
            order.addToOrderItems(orderItem)
        }
    }
    
    func save() throws {
        try context.save()
    }
    
}
