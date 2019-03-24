import Foundation
import CoreData

public struct OrderItemDetail {
    public var ingredient: IngredientDetail
    
    public init(ingredient: IngredientDetail) {
        self.ingredient = ingredient
    }
}

@objc(OrderItem)
public class OrderItem: NSManagedObject {

}
