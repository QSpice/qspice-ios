import Foundation
import CoreData
import Intents

public class RecipeController {
    public var recipeService: RecipeService
    
    public init(recipeService: RecipeService) {
        self.recipeService = recipeService
    }
    
    public lazy var recipesFetchedResults: NSFetchedResultsController<Recipe> = {
        let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResults = NSFetchedResultsController<Recipe>(fetchRequest: fetchRequest, managedObjectContext: recipeService.context, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResults
    }()
    
    public func deleteRecipe(recipe: Recipe) throws {
        recipeService.deleteRecipe(recipe)
        
        try deleteImageIfNeeded(name: recipe.uuid.uuidString)
        
        try recipeService.save()
        
        INInteraction.delete(with: recipe.name)
    }
    
    public func findRecipe(named name: String) -> Recipe? {
        do {
            return try recipeService.findRecipe(named: name)
        } catch {
            return nil
        }
    }
    
    private func deleteImageIfNeeded(name: String) throws {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        if let fileUrl = path?.appendingPathComponent("\(name).jpg") {
            if FileManager.default.fileExists(atPath: fileUrl.path) {
                try FileManager.default.removeItem(at: fileUrl)
            }
        }
    }
}
