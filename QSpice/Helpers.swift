import Foundation

struct Helpers {
    static func readCSV(file filename: String) throws -> String? {
        guard let filepath = Bundle.main.path(forResource: filename, ofType: "csv") else {
            return nil
        }

        return try String(contentsOfFile: filepath)
    }
}
