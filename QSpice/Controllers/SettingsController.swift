import Foundation

class SettingsController {
    func toggleWeightBasis() {
        var value: String
        if weightBasis == "Teaspoon" {
            value = "Tablespoon"
        } else {
            value = "Teaspoon"
        }
        
        UserDefaults.standard.set(value, forKey: "weight_basis")
    }
    
    var weightBasis: String {
        return UserDefaults.standard.string(forKey: "weight_basis") ?? "Teaspoon"
    }
}
