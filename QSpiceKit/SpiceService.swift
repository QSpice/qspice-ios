import CoreData

public class SpiceService {
    
    public private(set) var context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    public func countForSpices() throws -> Int {
        return try context.count(for: Spice.fetchRequest())
    }
    
    public func addSpice(name: String, weight: Float, color: String) {
        let spice = NSEntityDescription.insertNewObject(forEntityName: "Spice", into: context)
        spice.setValue(name, forKey: "name")
        spice.setValue(weight, forKey: "weight")
        spice.setValue(color, forKey: "color")
    }
    
    public func activeSpice(for slot: Int) throws -> Spice? {
        let request: NSFetchRequest<Spice> = Spice.fetchRequest()
        request.predicate = NSPredicate(format: "slot == %d", slot)
        
        let spices = try context.fetch(request)
        
        return spices.first
    }
    
    public func activeSpices() throws -> [Spice] {
        let request: NSFetchRequest<Spice> = Spice.fetchRequest()
        request.predicate = NSPredicate(format: "active == 1")
        
        let sort = NSSortDescriptor(key: "slot", ascending: true)
        request.sortDescriptors = [sort]
        
        return try context.fetch(request)
    }
    
    public func createListOrder(orderDetail: OrderDetail) -> Order {
        let order = Order(context: context)
        
        order.date = Date()
        order.quantity = orderDetail.quantity
        
        for item in orderDetail.orderItems where item.ingredient.quantity > 0 {
            let orderItem = OrderItem(context: context)
            
            let ingredient = Ingredient(context: context)
            ingredient.quantity = item.ingredient.quantity
            ingredient.metric = item.ingredient.metric
            ingredient.spice = item.ingredient.spice
            
            orderItem.ingredient = ingredient
            order.addToOrderItems(orderItem)
        }
        
        return order
        
    }
    
    public func createRecipeOrder(orderDetail: OrderDetail) -> Order? {
        guard let recipe = orderDetail.recipe else {
            return nil
        }
        
        let order = Order(context: context)
        
        order.date = Date()
        order.quantity = orderDetail.quantity
        order.recipe = recipe
        
        for ingredient in recipe.ingredients?.allObjects as? [Ingredient] ?? [] {
            let orderItem = OrderItem(context: context)
            
            orderItem.ingredient = ingredient
            order.addToOrderItems(orderItem)
        }
        
        return order
    }
    
    public func save() throws {
        try context.save()
    }
    
}
