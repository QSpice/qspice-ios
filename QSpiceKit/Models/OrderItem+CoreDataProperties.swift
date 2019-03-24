import Foundation
import CoreData

extension OrderItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OrderItem> {
        return NSFetchRequest<OrderItem>(entityName: "OrderItem")
    }

    @NSManaged public var ingredient: Ingredient
    @NSManaged public var order: Order

}
