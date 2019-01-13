import UIKit
import CoreBluetooth
import SCLAlertView

class BLEScanViewController: UITableViewController {

    var connected = false
    var peripherals = [CBPeripheral]()
    
    var connectionAlertResponder: SCLAlertViewResponder?
    
    lazy var connectionAlert: SCLAlertView = {
        let appearance = SCLAlertView.SCLAppearance(
            kTitleTop: 16.0,
            kWindowWidth: ((UIScreen.main.nativeBounds.width) / (UIScreen.main.nativeScale)) * 0.75,
            kTitleFont: Fonts.cStdMedium?.withSize(20.0) ?? UIFont.systemFont(ofSize: 20.0),
            kTextFont: Fonts.cStdBook?.withSize(16.0) ?? UIFont.systemFont(ofSize: 16.0),
            showCloseButton: false,
            showCircularIcon: false,
            contentViewCornerRadius: 4.0
        )
        
        return SCLAlertView(appearance: appearance)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Connect a device"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.contentInset = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.tableFooterView = UIView()
        
        scan()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        BLEManager.shared.delegate = self
    }
    
    @objc private func scan() {
        BLEManager.shared.scan()
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(stopScan), userInfo: nil, repeats: false)
        
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        let barButton = UIBarButtonItem(customView: activityIndicator)
        navigationItem.setRightBarButton(barButton, animated: true)
        
        activityIndicator.startAnimating()
        
    }
    
    @objc private func stopScan() {
        BLEManager.shared.stopScan()
        
        let barButton = UIBarButtonItem(title: "Scan", style: .plain, target: self, action: #selector(scan))
        navigationItem.setRightBarButton(barButton, animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return peripherals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = peripherals[indexPath.row].name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let peripheral = peripherals[indexPath.row]
        
        let title = "Attemping to connect to \(peripheral.name ?? "")"
        
        connectionAlert.customSubview = {
            let width = ((UIScreen.main.nativeBounds.width) / (UIScreen.main.nativeScale)) * 0.75
            let activityIndicator = UIActivityIndicatorView(style: .gray)
            activityIndicator.frame = CGRect(x: width / 2 - 20, y: 0, width: 20, height: 20)
            activityIndicator.startAnimating()
            return activityIndicator
        }()
        
        let timeout = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 10) {}
        connectionAlertResponder = connectionAlert.showCustom(title, subTitle: "", color: Colors.darkGrey, icon: UIImage(), closeButtonTitle: nil, timeout: timeout, colorStyle: 0xA429FF, colorTextButton: 0xFFFFFF, circleIconImage: nil, animationStyle: .bottomToTop)
        
        BLEManager.shared.connectTo(peripheral: peripheral)
        
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(stopConnect), userInfo: nil, repeats: false)
    }
    
    @objc private func stopConnect() {
        guard !connected else { return }
        
        BLEManager.shared.disconnect()
        connectionAlertResponder?.close()
        
        showAlert(title: AlertMessages.bleConnectFail.title, subtitle: AlertMessages.bleConnectFail.subtitle)
    }

}

extension BLEScanViewController: BLEManagerDelegate {
    func managerDidUpdateState(_ manager: BLEManager) {
        if manager.isPoweredOn {
            manager.scan()
        }
    }
    
    func manager(_ manager: BLEManager, didDiscover peripheral: CBPeripheral) {
        if !peripherals.contains(peripheral) {
            peripherals.append(peripheral)
        }
        
        tableView.reloadData()
    }
    
    func manager(_ manager: BLEManager, didConnect peripheral: CBPeripheral) {
        connected = true
        connectionAlertResponder?.close()
        navigationController?.popViewController(animated: true)
    }
    
    func manager(_ manager: BLEManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        stopConnect()
        
    }
    
}
