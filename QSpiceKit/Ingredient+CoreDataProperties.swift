import Foundation
import CoreData

extension Ingredient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ingredient> {
        return NSFetchRequest<Ingredient>(entityName: "Ingredient")
    }

    @NSManaged public var quantity: Int
    @NSManaged public var metric: Int
    @NSManaged public var orderItems: NSSet?
    @NSManaged public var recipe: Recipe?
    @NSManaged public var spice: Spice

}

// MARK: Generated accessors for orderItems
extension Ingredient {

    @objc(addOrderItemsObject:)
    @NSManaged public func addToOrderItems(_ value: OrderItem)

    @objc(removeOrderItemsObject:)
    @NSManaged public func removeFromOrderItems(_ value: OrderItem)

    @objc(addOrderItems:)
    @NSManaged public func addToOrderItems(_ values: NSSet)

    @objc(removeOrderItems:)
    @NSManaged public func removeFromOrderItems(_ values: NSSet)

}
