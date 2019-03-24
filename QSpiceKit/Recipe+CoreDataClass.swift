import Foundation
import CoreData

public struct RecipeDetail {
    public var image: Data?
    public var name: String
    public var link: String?
    public var content: String?
    public var ingredients: [Int: IngredientDetail]
    public var uuid: UUID?
    public var objectID: NSManagedObjectID?
    
    public init(image: Data?, name: String, link: String?, content: String?, ingredients: [Int: IngredientDetail], uuid: UUID?, objectID: NSManagedObjectID?) {
        self.image = image
        self.name = name
        self.link = link
        self.content = content
        self.ingredients = ingredients
        self.uuid = uuid
        self.objectID = objectID
    }
}

@objc(Recipe)
public class Recipe: NSManagedObject {

}
