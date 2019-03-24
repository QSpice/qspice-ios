import Foundation

public enum Metric: Int, CaseIterable {
    case teaspoon = 0
    case tablespoon = 1
    
    public var name: String {
        switch self {
        case .teaspoon: return "tsp"
        case .tablespoon: return "tbsp"
        }
    }
}

public struct Helpers {
    public static func readCSV(file filename: String) throws -> String? {
        guard let filepath = Bundle.main.path(forResource: filename, ofType: "csv") else {
            return nil
        }

        return try String(contentsOfFile: filepath)
    }
    
    public static func parseLevels(string: String) -> [Int] {
        let components = string.split(separator: " ")
        
        guard components.count > 1 else {
            return []
        }
        
        return components[1].split(separator: ",").map { Int($0) ?? 0 }
    }
    
    public static func metricTeaspoonMultiplier(from metric: Metric) -> Float {
        let multiplier: Float
        
        switch metric {
        case .tablespoon:
            multiplier = 3
        default:
            multiplier = 1
        }
        
        return multiplier
    }
}
