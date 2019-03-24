import UIKit
import CoreBluetooth
import QSpiceKit

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
        navigationController?.navigationBar.tintColor = Colors.darkGrey
        
        tableView.register(SettingCell.self, forCellReuseIdentifier: SettingCell.reuseId)
        tableView.contentInset = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        BLEManager.shared.delegate = self
        tableView.reloadData()
    }
    
    @objc private func disconnectDevice() {
        BLEManager.shared.disconnect()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [1, 1, 1][section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.reuseId, for: indexPath)
        
        if indexPath.section == 0 {
            cell.textLabel?.text = "Weight basis"
            cell.detailTextLabel?.text = controller.weightBasis
        } else if indexPath.section == 1 {
            let peripheral = BLEManager.shared.peripheral
            cell.textLabel?.text =  peripheral?.name ?? "Connect"
            cell.accessoryView = BLEManager.shared.peripheral == nil ? nil : {
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: cell.frame.height))
                button.setTitle("Disconnect", for: .normal)
                button.setTitleColor(Colors.maroon, for: .normal)
                button.addTarget(self, action: #selector(disconnectDevice), for: .touchUpInside)
                
                return button
            }()
        } else if indexPath.section == 2 {
            cell.textLabel?.text = "Reset all hints"
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["MEASUREMENTS", "CONNECT A DEVICE", "RESTORE SETTINGS"][section]
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Changing the weight basis changes the displayed weight of spices to the selected metric. Eg. 1 tsp of salt is 1.0g which would equate to 3.0g of salt in tablespoons."
        case 1:
            return "Scan and connect to a QSpice automatic spice dispenser."
            
        case 2:
            return "Resetting to default settings is an irreversible action."
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && BLEManager.shared.peripheral == nil {
            controller.toggleWeightBasis()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else if indexPath.section == 1 {
            navigationController?.pushViewController(BLEScanViewController(), animated: true)
        } else if indexPath.section == 2 {
            let action = AlertAction(title: "Yes I'm sure", action: {
                for value in HintMessages.keys.values {
                    UserDefaults.standard.set(nil, forKey: value)
                }
            }, color: Colors.maroon)
            showAlert(title: AlertMessages.resetHints.title, subtitle: AlertMessages.resetHints.subtitle, actions: [action], closeTitle: "No, cancel")
        }
    }

}

extension SettingsViewController: BLEManagerDelegate {
    func managerDidUpdateState(_ manager: BLEManager) {
        tableView.reloadData()
    }
    
    func manager(_ manager: BLEManager, didDisconnect peripheral: CBPeripheral) {
        tableView.reloadData()
    }
}
