import UIKit
import DynamicColor

protocol SpiceSelectionDelegate: class {
    func didSelect(spice: Spice, for slot: Int)
}

class SpiceSelectionViewController: UITableViewController {

    var spiceNumber: Int = 0
    
    var controller: SpiceSelectionController
    
    weak var delegate: SpiceSelectionDelegate?
    
    let searchController = UISearchController(searchResultsController: nil)
    
    init(controller: SpiceSelectionController) {
        self.controller = controller
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSpices()

        title = "Spice Slot \(spiceNumber)"

        navigationController?.navigationBar.tintColor = UIColor(r: 77.0, g: 77.0, b: 77.0, a: 1.0)
        
        tableView.register(SpiceCell.self, forCellReuseIdentifier: SpiceCell.reuseId)
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets.zero
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func loadSpices() {
        do {
            try controller.spicesFetchedResults.performFetch()
        } catch {
            print("Could not load spices: ", error.localizedDescription)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return controller.spicesFetchedResults.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.spicesFetchedResults.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SpiceCell.reuseId, for: indexPath) as! SpiceCell
        
        let spice = controller.spicesFetchedResults.object(at: indexPath)
        
        if spice.active {
            cell.type = .displayActive
        } else {
            cell.type = .display
        }
        
        cell.spiceNameLabel.text = spice.name
        cell.weight = "\(spice.weight)"
        cell.color = UIColor(hexString: spice.color)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let spice = controller.spicesFetchedResults.object(at: indexPath)
        
        delegate?.didSelect(spice: spice, for: spiceNumber)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

}

extension SpiceSelectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        controller.updateSpiceResults(query: searchController.searchBar.text ?? "")
        tableView.reloadData()
    }
}
