import Foundation

struct Helpers {
    static func readCSV(file filename: String) throws -> String? {
        guard let filepath = Bundle.main.path(forResource: filename, ofType: "csv") else {
            return nil
        }

        return try String(contentsOfFile: filepath)
    }
    
    static func parseLevels(string: String) -> [Int] {
        let components = string.split(separator: " ")
        
        guard components.count > 1 else {
            return []
        }
        
        return components[1].split(separator: ",").map { Int($0) ?? 0 }
    }
}
