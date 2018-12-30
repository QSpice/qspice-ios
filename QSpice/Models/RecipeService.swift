import CoreData

class RecipeService {
    private(set) var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addRecipe(recipeDetail: RecipeDetail) -> Recipe {
        let recipe = Recipe(context: context)
        
        recipe.name = recipeDetail.name
        recipe.link = recipeDetail.link
        recipe.content = recipeDetail.content
        recipe.uuid = UUID()
        
        for ingredientDetail in recipeDetail.ingredients.values {
            let ingredient = Ingredient(context: context)
            ingredient.amount = ingredientDetail.amount
            ingredient.metric = ingredientDetail.metric
            ingredient.spice = ingredientDetail.spice
            recipe.addToIngredients(ingredient)
        }

        return recipe
        
    }
    
    func updateRecipe(recipeDetail: RecipeDetail) {
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
            ingredient.amount = ingredientDetail.amount
            ingredient.metric = ingredientDetail.metric
            ingredient.spice = ingredientDetail.spice
            recipe.addToIngredients(ingredient)
        }
        
    }
    
    func deleteRecipe(_ recipe: Recipe) {
        context.delete(recipe)
    }
    
    func save() throws {
        try context.save()
    }
}
