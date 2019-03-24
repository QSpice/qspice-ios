import Foundation
import CoreData

@objc(Spice)
public class Spice: NSManagedObject {
    static func spiceQuantity(from index: Int) -> (string: String, float: Float) {
        let wholeNumber = index / 4
        let fractionalPart = index % 4
        
        var stringValue = wholeNumber == 0 ? "" : "\(wholeNumber) "
        let floatValue = Float(wholeNumber) + Float(fractionalPart) * 0.25
        
        switch fractionalPart {
        case 1:
            stringValue += "¼"
        case 2:
            stringValue += "½"
        case 3:
            stringValue += "¾"
        default:
            if wholeNumber == 0 {
                stringValue = "0"
            }
        }
        
        return (stringValue, floatValue)
        
    }
    
    static func mapSpiceWeight(value: Float, metric: String) -> Float {
        if metric == "Tablespoon" {
            return value * 3
        } else {
            return value
        }
    }
}
