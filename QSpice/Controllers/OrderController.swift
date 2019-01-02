import Foundation
import CoreData

struct OrderItemDetail {
    var ingredient: IngredientDetail
}

struct OrderDetail {
    var recipe: Recipe?
    var orderItems: [OrderItemDetail]
    var quantity: Int
}

class OrderController {
    var spiceService: SpiceService
    
    var activeSpices: [Spice] = []
    
    var order = OrderDetail(recipe: nil, orderItems: [], quantity: 1)
    
    init(spiceService: SpiceService) {
        self.spiceService = spiceService
        
        clearOrder()
    }
    
    func updateIngredient(amount: Float, metric: String, for slot: Int) {
        order.orderItems[slot].ingredient.amount = amount
        order.orderItems[slot].ingredient.metric = metric
    }
    
    func fetchActiveSpices() {
        do {
            let spices = try spiceService.activeSpices()
            
            activeSpices = spices
        } catch {
            print("Could not fetch active spices", error.localizedDescription)
        }
    }
    
    func selectRecipe(_ recipe: Recipe) {
        if recipe.uuid == order.recipe?.uuid {
            order.recipe = nil
        } else {
            order.recipe = recipe
        }
    }
    
    lazy var recipesFetchedResults: NSFetchedResultsController<Recipe> = {
        let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResults = NSFetchedResultsController<Recipe>(fetchRequest: fetchRequest, managedObjectContext: spiceService.context, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResults
    }()
    
    lazy var ordersFetchedResults: NSFetchedResultsController<Order> = {
        let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResults = NSFetchedResultsController<Order>(fetchRequest: fetchRequest, managedObjectContext: spiceService.context, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResults
    }()
    
    func updateOrder(quantity: Int) -> Int {
        order.quantity = max(order.quantity + quantity, 1)
        
        return order.quantity
    }
    
    func isValidListOrder() -> Bool {
        for item in order.orderItems where item.ingredient.amount > 0 {
            return true
        }
        
        return false
    }
    
    func createListOrder() throws {
        spiceService.createListOrder(orderDetail: order)
        
        try spiceService.save()
    }
    
    func createRecipeOrder() throws {
        spiceService.createRecipeOrder(orderDetail: order)
        
        try spiceService.save()
    }
    
    func clearOrder() {
        fetchActiveSpices()
        order.orderItems.removeAll()
        order.recipe = nil
        order.quantity = 1
        
        for activeSpice in activeSpices {
            order.orderItems.append(OrderItemDetail(ingredient: IngredientDetail(spice: activeSpice, amount: 0.0, metric: "tsp")))
        }
    }
}
