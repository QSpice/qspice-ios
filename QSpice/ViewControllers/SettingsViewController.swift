import UIKit

class SettingsViewController: UITableViewController {
    var controller: SettingsController
    
    init(controller: SettingsController) {
        self.controller = controller
        
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = navigationController?.tabBarItem.title
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = .white
        let titleAttributes = [NSAttributedString.Key.foregroundColor: Colors.darkGrey]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        navigationController?.navigationBar.largeTitleTextAttributes = titleAttributes
        
        tableView.register(SettingCell.self, forCellReuseIdentifier: SettingCell.reuseId)
        tableView.contentInset = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [1, 1][section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.reuseId, for: indexPath)
        
        if indexPath.section == 0 {
            cell.textLabel?.text = "Weight Basis"
            cell.detailTextLabel?.text = controller.weightBasis
        } else if indexPath.section == 1 {
            cell.textLabel?.text = "Connect"
        }
        
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["MEASUREMENTS", "CONNECT A DEVICE"][section]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            controller.toggleWeightBasis()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

}
