import Foundation
import CoreData
import Intents
import QSpiceKit

enum RecipeError: Error {
    case invalidName
}

class RecipeDetailController {
    
    var recipeService: RecipeService
    
    var recipeDetail: RecipeDetail
    
    init(recipeService: RecipeService) {
        self.recipeService = recipeService
        self.recipeDetail = RecipeDetail(image: nil, name: "", link: "", content: "", ingredients: [:], uuid: nil, objectID: nil)
    }
    
    init(recipeService: RecipeService, recipeDetail: RecipeDetail) {
        self.recipeService = recipeService
        self.recipeDetail = recipeDetail
        
        reorderIngredients()
    }

    func addIngredient(_ spice: Spice, for slot: Int) {
        
        for (key, value) in recipeDetail.ingredients where value.spice.name == spice.name {
            recipeDetail.ingredients.removeValue(forKey: key)
        }
        
        recipeDetail.ingredients[slot] = IngredientDetail(spice: spice, quantity: 1, metric: 0)
        
    }
    
    func removeIngredient(for slot: Int) {
        recipeDetail.ingredients.removeValue(forKey: slot)
    }
    
    func updateIngredient(quantity: Int, for slot: Int) {
        recipeDetail.ingredients[slot]?.quantity = quantity
    }
    
    func updateIngredient(metric: Metric, for slot: Int) {
        recipeDetail.ingredients[slot]?.metric = metric.rawValue
    }
    
    func addRecipe(name: String, link: String, content: String, image: Data?) throws {
        guard !name.isEmpty else {
            throw RecipeError.invalidName
        }
        
        recipeDetail.name = name
        recipeDetail.link = link == "" ? nil : link
        recipeDetail.content = content == "" ? nil : content
        
        let recipe = recipeService.addRecipe(recipeDetail: recipeDetail)
        
        saveImageIfNeeded(name: recipe.uuid.uuidString, image: image)
        
        try recipeService.save()
        
        let intent = DispenseRecipeIntent()
        intent.name = recipeDetail.name
        
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.identifier = recipeDetail.name
        interaction.donate(completion: nil)
        
        reorderIngredients()
    }
    
    func updateRecipe(name: String, link: String, content: String, image: Data?) throws {
        recipeDetail.name = name
        recipeDetail.link = link == "" ? nil : link
        recipeDetail.content = content == "" ? nil : content
        
        recipeService.updateRecipe(recipeDetail: recipeDetail)
        
        saveImageIfNeeded(name: recipeDetail.uuid!.uuidString, image: image)
        
        try recipeService.save()
        
        reorderIngredients()
    }
    
    private func saveImageIfNeeded(name: String, image: Data?) {
        if let image = image {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            
            if let filePath = path?.appendingPathComponent("\(name).jpg") {
                do {
                    try image.write(to: filePath, options: .atomic)
                } catch {
                    print("Could not save file: ", error.localizedDescription)
                }
            }
        }
    }
    
    private func reorderIngredients() {
        let ingredients = recipeDetail.ingredients.values.sorted(by: { $0.spice.name < $1.spice.name })
        recipeDetail.ingredients.removeAll()
        for (i, ingredient) in ingredients.enumerated() {
            recipeDetail.ingredients[i + 1] = ingredient
        }
    }
}
