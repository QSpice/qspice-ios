import Foundation
import CoreData

@objc(Spice)
public class Spice: NSManagedObject {
    static func mapSpiceAmount(value: Float) -> String {
        if value == 0.25 {
            return "¼"
        } else if value == 0.50 {
            return "½"
        } else {
            return "\(Int(value))"
        }
    }
    
    static func spiceQuantity(from index: Int) -> (string: String, float: Float) {
        switch index {
        case 0:
            return ("0", 0)
        case 1:
            return ("¼", 0.25)
        case 2:
            return ("½", 0.5)
        default:
            let value = index - 2
            return ("\(value)", Float(value))
        }
        
    }
    
    static func mapSpiceWeight(value: Float, metric: String) -> Float {
        if metric == "Tablespoon" {
            return value * 3
        } else {
            return value
        }
    }
}
