import UIKit
import DynamicColor
import QSpiceKit

protocol SpiceSelectionDelegate: class {
    func didSelect(spice: Spice, for slot: Int)
}

class SpiceSelectionViewController: UITableViewController {

    var spiceNumber: Int = 0
    
    private(set) var controller: SpiceSelectionController
    weak var delegate: SpiceSelectionDelegate?
    
    init(controller: SpiceSelectionController) {
        self.controller = controller
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.dimsBackgroundDuringPresentation = false
        controller.hidesNavigationBarDuringPresentation = false
        
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSpices()
        prepareView()
    }
    
    private func loadSpices() {
        do {
            try controller.spicesFetchedResults.performFetch()
        } catch {
            showAlert(title: AlertMessages.loadSpices.title, subtitle: AlertMessages.loadSpices.subtitle)
        }
    }
    
    // MARK: UITableView Delegate and Data Source
    
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
        cell.weight = String(format: "%.1f", Spice.mapSpiceWeight(value: spice.weight, metric: controller.weightBasis))
        cell.color = UIColor(hexString: spice.color)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let spice = controller.spicesFetchedResults.object(at: indexPath)
        
        delegate?.didSelect(spice: spice, for: spiceNumber)
    }
    
    // MARK: View Management

    private func prepareView() {
        title = "Spice Slot \(spiceNumber)"
        
        // setup search controller
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        navigationController?.navigationBar.tintColor = UIColor(r: 77.0, g: 77.0, b: 77.0, a: 1.0)
        
        tableView.register(SpiceCell.self, forCellReuseIdentifier: SpiceCell.reuseId)
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
    }
    
}

// MARK: UISearchResults Updating

extension SpiceSelectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        do {
            try controller.updateSpiceResults(query: searchController.searchBar.text ?? "")
        } catch {
            showAlert(title: AlertMessages.filterSpices.title, subtitle: AlertMessages.filterSpices.subtitle)
        }
        tableView.reloadData()
    }
}
