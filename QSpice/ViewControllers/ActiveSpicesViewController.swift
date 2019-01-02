import UIKit

class ActiveSpicesViewController: UITableViewController {

    var controller: SpiceController
    
    init(controller: SpiceController) {
        self.controller = controller
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = navigationController?.tabBarItem.title
        
        controller.fetchActiveSpices()
        
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.prefersLargeTitles = true
        let titleAttributes = [NSAttributedString.Key.foregroundColor: Colors.darkGrey]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        navigationController?.navigationBar.largeTitleTextAttributes = titleAttributes
        
        tableView.register(SpiceCell.self, forCellReuseIdentifier: SpiceCell.reuseId)
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.contentInset = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        controller.fetchActiveSpices()
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppConfig.maxNumberOfActiveSpices
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SpiceCell.reuseId, for: indexPath) as! SpiceCell

        cell.numberLabel.text = "\(indexPath.row + 1)"
        
        if let activeSpice = controller.activeSpices[indexPath.row + 1] {
            cell.type = .display
            cell.color = UIColor(hexString: activeSpice.color)
            cell.spiceNameLabel.text = activeSpice.name
            cell.weight = String(format: "%.1f", Spice.mapSpiceWeight(value: activeSpice.weight, metric: controller.weightBasis))
        } else {
            cell.type = .unselected
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destination = SpiceSelectionViewController(controller: SpiceSelectionController(spiceService: controller.spiceService))
        destination.spiceNumber = indexPath.row + 1
        destination.delegate = self
        
        navigationController?.pushViewController(destination, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let activeSpice = self.controller.activeSpices[indexPath.row + 1] else {
            return nil
        }
        
        let clearAction = UIContextualAction(style: .destructive, title: "Clear") { [weak self] (_, _, completion) in
            if let self = self {
                self.controller.updateActive(spice: activeSpice, slot: -1)
                self.controller.fetchActiveSpices()
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            
            completion(false)
        }
        
        clearAction.image = UIImage(named: "erase")
        clearAction.backgroundColor = Colors.lightGrey.lighter()
        
        let config = UISwipeActionsConfiguration(actions: [clearAction])
        
        return config
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return controller.activeSpices[indexPath.row + 1] != nil
    }

}

extension ActiveSpicesViewController: SpiceSelectionDelegate {
    func didSelect(spice: Spice, for slot: Int) {
        print(spice.name)
        
        controller.updateActive(spice: spice, slot: slot)
        
        navigationController?.popViewController(animated: true)
    }
    
}
