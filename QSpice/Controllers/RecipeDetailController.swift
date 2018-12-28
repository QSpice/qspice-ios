import Foundation

struct RecipeDetail {
    var imagePath: String?
    var name: String
    var link: String
    var content: String
    var spices: [Int: Spice]
}

class RecipeDetailController {
    
    var recipeService: RecipeService
    
    var recipeDetail: RecipeDetail
    
    init(recipeService: RecipeService) {
        self.recipeService = recipeService
        self.recipeDetail = RecipeDetail(imagePath: nil, name: "", link: "", content: "", spices: [:])
    }
    
    init(recipeService: RecipeService, recipeDetail: RecipeDetail) {
        self.recipeService = recipeService
        self.recipeDetail = recipeDetail
    }

    func addSpice(_ spice: Spice, for slot: Int) {
        
        for (key, value) in recipeDetail.spices where value.name == spice.name {
            recipeDetail.spices.removeValue(forKey: key)
        }
        
        recipeDetail.spices[slot] = spice
        
    }
    
    func addRecipe(name: String, link: String, content: String, image: Data?) throws {
        recipeDetail.name = name
        recipeDetail.link = link
        recipeDetail.content = content
        
        recipeService.addRecipe(recipeDetail: recipeDetail)
        
        try recipeService.save()
    }
    
    func updateRecipe(name: String, link: String, content: String, image: Data?) throws {
        
    }
}
