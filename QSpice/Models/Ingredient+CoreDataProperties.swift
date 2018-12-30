import Foundation
import CoreData

extension Ingredient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ingredient> {
        return NSFetchRequest<Ingredient>(entityName: "Ingredient")
    }

    @NSManaged public var amount: Float
    @NSManaged public var metric: String
    @NSManaged public var recipe: Recipe
    @NSManaged public var spice: Spice

}
