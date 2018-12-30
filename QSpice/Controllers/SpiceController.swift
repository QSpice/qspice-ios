import CoreData

class SpiceController {
    
    var spiceService: SpiceService
    
    var activeSpices: [Int: Spice] = [:]
    
    init(spiceService: SpiceService) {
        self.spiceService = spiceService
    }
    
    func initializeSpicesIfNeeded() {
        do {
            let spiceCount = try spiceService.countForSpices()
            print(spiceCount)
            
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
            
        } catch {
            print("Could not initialize spices", error.localizedDescription)
        }
    }
    
    func updateActive(spice: Spice, slot: Int) {
        do {
            
            if slot == -1 {
                spice.active = false
                spice.slot = -1
                return
            }
            
            if let currentActiveSpice = try spiceService.activeSpice(for: slot) {
                currentActiveSpice.active = false
                currentActiveSpice.slot = -1
            }
            
            spice.active = true
            spice.slot = Int32(slot)
            
            try spiceService.save()
            
            invalidateActiveSpices()
            
        } catch {
            print("Could not update active spice", error.localizedDescription)
        }
    }
    
    func fetchActiveSpices() {
        do {
            let spices = try spiceService.activeSpices()

            activeSpices = spices.reduce(into: [:]) { spices, spice in
                spices[Int(spice.slot)] = spice
            }
        } catch {
            print("Could not fetch active spices", error.localizedDescription)
        }
    }
    
    private func invalidateActiveSpices() {
        activeSpices.removeAll()
    }
    
}
