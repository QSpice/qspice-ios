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

enum OrderError: Error {
    case notConnected
    case lowLevel(String)
    case missingSpices
    case noSpices
}

class OrderController {
    var spiceService: SpiceService
    
    var activeSpices: [Spice] = []
    
    var order = OrderDetail(recipe: nil, orderItems: [], quantity: 1)
    
    init(spiceService: SpiceService) {
        self.spiceService = spiceService
        
        clearOrder()
    }
    
    func updateIngredient(quantity: Int, for slot: Int) {
        order.orderItems[slot].ingredient.quantity = quantity
    }
    
    func updateIngredient(metric: Metric, for slot: Int) {
        order.orderItems[slot].ingredient.metric = metric.rawValue
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
        for item in order.orderItems where item.ingredient.quantity > 0 {
            return true
        }
        
        return false
    }
    
    func createListOrder(spiceLevels: [Int]) throws {
        guard BLEManager.shared.isReady else {
            throw OrderError.notConnected
        }
        
        try verify(levels: spiceLevels)
        
        let newOrder = spiceService.createListOrder(orderDetail: order)
        try spiceService.save()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            BLEManager.shared.write(message: self.generateOrderMessage(order: newOrder))
        }
    }
    
    func createRecipeOrder() throws {
        guard BLEManager.shared.isReady else {
            throw OrderError.notConnected
        }
        
        let ingredients = order.recipe?.ingredients?.allObjects as? [Ingredient] ?? []
        
        if ingredients.isEmpty {
            throw OrderError.noSpices
        }
        
        for ingredient in ingredients {
            if !activeSpices.contains(ingredient.spice) {
                throw OrderError.missingSpices
            }
        }
        
        try spiceService.save()
        
        if let newOrder = spiceService.createRecipeOrder(orderDetail: order) {
            BLEManager.shared.write(message: generateOrderMessage(order: newOrder))
        }
    }
    
    private func generateOrderMessage(order: Order) -> String {
        let orderItems = order.orderItems?.allObjects as? [OrderItem] ?? []
        
        var data = [String]()
        
        for item in orderItems.sorted(by: { $0.ingredient.spice.slot < $1.ingredient.spice.slot }) {
            let multiplier = Helpers.metricTeaspoonMultiplier(from: Metric(rawValue: item.ingredient.metric) ?? .teaspoon)
            
            let weight = item.ingredient.spice.weight * multiplier
            let quantity = Spice.spiceQuantity(from: item.ingredient.quantity).float
            
            let total =  String(format: "%.1f", weight * quantity * Float(order.quantity))
            
            data.append("\(item.ingredient.spice.slot)|\(total)")
        }
        
        return "DATA ".appending(data.joined(separator: ","))
    }
    
    func clearOrder() {
        fetchActiveSpices()
        order.orderItems.removeAll()
        order.recipe = nil
        order.quantity = 1
        
        for activeSpice in activeSpices {
            order.orderItems.append(OrderItemDetail(ingredient: IngredientDetail(spice: activeSpice, quantity: 0, metric: 0)))
        }
    }
    
    private func verify(levels: [Int]) throws {
        if levels.isEmpty {
            return
        }
        
        var lowLevels = [String]()
        
        for i in 0..<order.orderItems.count where levels[i] <= 15 && order.orderItems[i].ingredient.quantity > 0 {
            lowLevels.append("\(i+1) (\(order.orderItems[i].ingredient.spice.name))")
        }
        
        if !lowLevels.isEmpty {
            throw OrderError.lowLevel("\n" + lowLevels.joined(separator: ", "))
        }
    }
}
