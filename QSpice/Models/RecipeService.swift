import CoreData

class RecipeService {
    private(set) var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addRecipe(recipeDetail: RecipeDetail) {
        let recipe = Recipe(context: context)
        
        recipe.name = recipeDetail.name
        recipe.link = recipeDetail.link
        recipe.content = recipeDetail.content
        
        
        for spice in recipeDetail.spices.values {
            recipe.addToSpices(spice)
        }
    }
    
    func save() throws {
        try context.save()
    }
}
