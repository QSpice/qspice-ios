import CoreData

class SpiceController {
    
    var spiceService: SpiceService
    
    var activeSpices: [Int: Spice] = [:]
    
    var weightBasis: String {
        return UserDefaults.standard.string(forKey: "weight_basis") ?? "Teaspoon"
    }
    
    init(spiceService: SpiceService) {
        self.spiceService = spiceService
    }
    
    func initializeSpicesIfNeeded() throws {
        let spiceCount = try spiceService.countForSpices()
        
        guard spiceCount == 0 else {
            return
        }
        
        if let contents = try Helpers.readCSV(file: AppConfig.spiceFile) {
        
            let rows = contents.components(separatedBy: "\n")
            
            for row in rows where row != "" {
                let attributes = row.components(separatedBy: ",")
                spiceService.addSpice(name: attributes[0], weight: Float(attributes[1]) ?? 0.0, color: attributes[2])
            }
            
            try spiceService.save()
        }
    }
    
    func updateActive(spice: Spice, slot: Int) throws {
        if slot == -1 {
            spice.active = false
            spice.slot = -1
        }
        
        if let currentActiveSpice = try spiceService.activeSpice(for: slot) {
            currentActiveSpice.active = false
            currentActiveSpice.slot = -1
        } else {
            spice.active = true
            spice.slot = Int32(slot)
        }
        
        try spiceService.save()
        
        invalidateActiveSpices()
    }
    
    func fetchActiveSpices() throws {
        let spices = try spiceService.activeSpices()

        activeSpices = spices.reduce(into: [:]) { spices, spice in
            spices[Int(spice.slot)] = spice
        }
    }
    
    private func invalidateActiveSpices() {
        activeSpices.removeAll()
    }
    
}
