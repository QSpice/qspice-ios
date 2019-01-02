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
    static func nextAmount(after current: Float, increment: Bool, allowZero: Bool = false) -> Float {
        var numeric: Float = 0.0

        if increment {
            if current == 0.0 {
                numeric = 0.25
            } else if current == 0.25 {
                numeric = 0.5
            } else if current == 0.5 {
                numeric = 1.0
            } else {
                numeric = current + 1.0
            }
        } else {
            if current == 0.25 && allowZero {
                numeric = 0.0
            } else if current == 0.5 {
                numeric = 0.25
            } else if current == 1.0 {
                numeric = 0.5
            } else {
                numeric = max(allowZero ? 0.0 : 0.25, current - 1.0)
            }
        }
        
        return numeric
    }
    
    static func mapSpiceWeight(value: Float, metric: String) -> Float {
        if metric == "Tablespoon" {
            return value * 3
        } else {
            return value
        }
    }
}
