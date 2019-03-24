import Foundation
import CoreData

public struct IngredientDetail {
    public var spice: Spice
    public var quantity: Int
    public var metric: Int
    
    public init(spice: Spice, quantity: Int, metric: Int) {
        self.spice = spice
        self.quantity = quantity
        self.metric = metric
    }
}

@objc(Ingredient)
public class Ingredient: NSManagedObject {

}
