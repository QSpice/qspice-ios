import Intents
import QSpiceKit

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        return DispenseRecipeIntentHandler()
    }
    
}

class DispenseRecipeIntentHandler: NSObject, DispenseRecipeIntentHandling {
    lazy var recipeController = RecipeController(recipeService: RecipeService(context: CoreDataManager.shared.context))
    lazy var orderController = OrderController(spiceService: SpiceService(context: CoreDataManager.shared.context))
    
    var spiceLevels: [Int] = []
    
    func confirm(intent: DispenseRecipeIntent, completion: @escaping (DispenseRecipeIntentResponse) -> Void) {
        
        guard let recipeName = intent.name else {
            completion(.failure(reason: "Recipe not found."))
            return
        }
        
        if orderController.order.recipe == nil, let recipe = recipeController.findRecipe(named: recipeName) {
            orderController.selectRecipe(recipe)
            completion(DispenseRecipeIntentResponse(code: .success, userActivity: nil))
        } else {
            guard BLEManager.shared.isReady else {
                completion(.failure(reason: AlertMessages.noOrderBleConnect.subtitle))
                return
            }
            
            BLEManager.shared.write(message: "POLL")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                do {
                    try self.orderController.verifyRecipe(levels: self.spiceLevels)
                    
                } catch OrderError.lowLevel(let levels) {
                    completion(.failure(reason: "\(AlertMessages.spiceLevels.subtitle) \(levels)"))
                    return
                } catch {
                    completion(.failure(reason: "Could not complete your order"))
                    return
                }
            }
            
            completion(DispenseRecipeIntentResponse(code: .success, userActivity: nil))
        }
        
    }
    
    func handle(intent: DispenseRecipeIntent, completion: @escaping (DispenseRecipeIntentResponse) -> Void) {
        
        do {
            try orderController.createRecipeOrder(spiceLevels: [])
        } catch OrderError.notConnected {
            completion(.failure(reason: AlertMessages.noOrderBleConnect.subtitle))
            return
        } catch OrderError.noSpices {
            completion(.failure(reason: AlertMessages.noOrderNoSpices.subtitle))
            return
        } catch OrderError.missingSpices {
            completion(.failure(reason: AlertMessages.noOrderMissingSpices.subtitle))
            return
        } catch OrderError.exceededAmount {
            completion(.failure(reason: AlertMessages.noOrderExceededAmount.subtitle))
            return
        } catch {
            completion(.failure(reason: "Could not complete your order"))
            return
        }
        
        completion(DispenseRecipeIntentResponse(code: .success, userActivity: nil))
    }
    
}

extension DispenseRecipeIntentHandler: BLEManagerDelegate {
    func manager(_ manager: BLEManager, didReceive message: String, error: Error?) {
        if message.contains("OK") {
            spiceLevels = Helpers.parseLevels(string: message)
            return
        }
    }
}
