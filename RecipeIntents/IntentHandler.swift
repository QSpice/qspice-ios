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
        guard UserDefaults(suiteName: "group.com.electriapp.QSpice")?.string(forKey: "ble_identifier") != nil else {
            completion(.failure(reason: AlertMessages.noOrderBleConnect.subtitle))
            return
        }
        
        BLEManager.shared.powerUp()

        completion(DispenseRecipeIntentResponse(code: .success, userActivity: nil))
    }
    
    func handle(intent: DispenseRecipeIntent, completion: @escaping (DispenseRecipeIntentResponse) -> Void) {
        let bleIdentifier = UserDefaults(suiteName: "group.com.electriapp.QSpice")?.string(forKey: "ble_identifier")
        let recipeController = RecipeController(recipeService: RecipeService(context: CoreDataManager.shared.context))
        let orderController = OrderController(spiceService: SpiceService(context: CoreDataManager.shared.context))

        guard let recipeName = intent.name, let recipe = recipeController.findRecipe(named: recipeName) else {
            completion(.failure(reason: "Recipe not found."))
            return
        }
        
        orderController.selectRecipe(recipe)
        BLEManager.shared.reconnect(uuid: UUID(uuidString: bleIdentifier!)!)
        
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
