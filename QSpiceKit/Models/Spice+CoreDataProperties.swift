import Foundation
import CoreData

extension Spice {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Spice> {
        return NSFetchRequest<Spice>(entityName: "Spice")
    }

    @NSManaged public var active: Bool
    @NSManaged public var color: String
    @NSManaged public var name: String
    @NSManaged public var slot: Int64
    @NSManaged public var weight: Float
    @NSManaged public var ingredients: NSSet?

}

// MARK: Generated accessors for ingredients
extension Spice {

    @objc(addIngredientsObject:)
    @NSManaged public func addToIngredients(_ value: Ingredient)

    @objc(removeIngredientsObject:)
    @NSManaged public func removeFromIngredients(_ value: Ingredient)

    @objc(addIngredients:)
    @NSManaged public func addToIngredients(_ values: NSSet)

    @objc(removeIngredients:)
    @NSManaged public func removeFromIngredients(_ values: NSSet)

}
