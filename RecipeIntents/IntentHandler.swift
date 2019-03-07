import Intents
import QSpiceKit

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        return DispenseRecipeIntentHandler()
    }
    
}

class DispenseRecipeIntentHandler: NSObject, DispenseRecipeIntentHandling {
    func confirm(intent: DispenseRecipeIntent, completion: @escaping (DispenseRecipeIntentResponse) -> Void) {
        print("confirm")
        
        
        completion(DispenseRecipeIntentResponse(code: .success, userActivity: nil))
    }
    
    func handle(intent: DispenseRecipeIntent, completion: @escaping (DispenseRecipeIntentResponse) -> Void) {
        print("handle")
        
        completion(DispenseRecipeIntentResponse(code: .success, userActivity: nil))
    }
    
}
