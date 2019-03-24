import CoreData

public class RecipeService {
    public private(set) var context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    public func addRecipe(recipeDetail: RecipeDetail) -> Recipe {
        let recipe = Recipe(context: context)
        
        recipe.name = recipeDetail.name
        recipe.link = recipeDetail.link
        recipe.content = recipeDetail.content
        recipe.uuid = UUID()
        
        for ingredientDetail in recipeDetail.ingredients.values {
            let ingredient = Ingredient(context: context)
            ingredient.quantity = ingredientDetail.quantity
            ingredient.metric = ingredientDetail.metric
            ingredient.spice = ingredientDetail.spice
            recipe.addToIngredients(ingredient)
        }

        return recipe
        
    }
    
    public func findRecipe(named name: String) throws -> Recipe? {
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        
        return try context.fetch(request).first
    }
    
    public func updateRecipe(recipeDetail: RecipeDetail) {
        guard let objectID = recipeDetail.objectID, let recipe = context.object(with: objectID) as? Recipe else {
            return
        }
        
        recipe.name = recipeDetail.name
        recipe.link = recipeDetail.link
        recipe.content = recipeDetail.content
        
        for ingredient in recipe.ingredients?.allObjects as? [NSManagedObject] ?? [] {
            context.delete(ingredient)
        }
        
        for ingredientDetail in recipeDetail.ingredients.values {
            let ingredient = Ingredient(context: context)
            ingredient.quantity = ingredientDetail.quantity
            ingredient.metric = ingredientDetail.metric
            ingredient.spice = ingredientDetail.spice
            recipe.addToIngredients(ingredient)
        }
        
    }
    
    public func deleteRecipe(_ recipe: Recipe) {
        context.delete(recipe)
    }
    
    public func save() throws {
        try context.save()
    }
}
