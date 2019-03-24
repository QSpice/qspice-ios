import Foundation
import CoreData

public struct OrderDetail {
    public var recipe: Recipe?
    public var orderItems: [OrderItemDetail]
    public var quantity: Int
    
    public init(recipe: Recipe?, orderItems: [OrderItemDetail], quantity: Int) {
        self.recipe = recipe
        self.orderItems = orderItems
        self.quantity = quantity
    }
}

@objc(Order)
public class Order: NSManagedObject {

}
