import CoreData

class SpiceSelectionController {
    
    var spiceService: SpiceService
    
    var weightBasis: String {
        return UserDefaults.standard.string(forKey: "weight_basis") ?? "Teaspoon"
    }
    
    init(spiceService: SpiceService) {
        self.spiceService = spiceService
    }
    
    func updateSpiceResults(query: String) {
        var predicate: NSPredicate?
        
        if query.count > 0 {
            predicate = NSPredicate(format: "name contains[cd] %@", query)
        } else {
            predicate = nil
        }
        
        spicesFetchedResults.fetchRequest.predicate = predicate
        
        do {
            try spicesFetchedResults.performFetch()
        } catch {
            print("Could not filter search results: ", error.localizedDescription)
        }
        
    }
    
    lazy var spicesFetchedResults: NSFetchedResultsController<Spice> = {
        let fetchRequest: NSFetchRequest<Spice> = Spice.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResults = NSFetchedResultsController<Spice>(fetchRequest: fetchRequest, managedObjectContext: spiceService.context, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResults
    }()
    
}
