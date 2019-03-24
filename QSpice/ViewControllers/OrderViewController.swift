import UIKit
import QSpiceKit

class OrderViewController: UIViewController {

    let quantityView = QuantityView()
    var controller: OrderController
    var messageTimer: Timer?
    
    init(controller: OrderController) {
        self.controller = controller
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isCreatingOrder: Bool = false {
        didSet {
            if isCreatingOrder {
                placeOrderButton.isEnabled = false
            } else {
                placeOrderButton.isEnabled = true
            }
            
            placeOrderButton.isLoading = !placeOrderButton.isEnabled
        }
    }
    
    let tableView: UITableView = {
        let tableView = UITableView()
        
        return tableView
    }()
    
    let placeOrderButton: ActionButton = {
        let button = ActionButton()
        button.setTitle("Place Order", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = Colors.lightGrey
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "cross"), style: .plain, target: self, action: #selector(cancelOrder))
        
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.contentInset = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
        placeOrderButton.addTarget(self, action: #selector(checkDeviceStatus), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        BLEManager.shared.delegate = self
        
        controller.clearOrder()
    }
    
    @objc func cancelOrder() {
        dismiss(animated: true)
    }
    
    @objc func checkDeviceStatus() {
        if BLEManager.shared.isReady {
            isCreatingOrder = true
            BLEManager.shared.write(message: "POLL")
            messageTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(messageTimeout), userInfo: nil, repeats: false)
        } else {
            showAlert(title: AlertMessages.noOrderBleConnect.title, subtitle: AlertMessages.noOrderBleConnect.subtitle)
        }
    }
    
    @objc func messageTimeout() {
        isCreatingOrder = false
        messageTimer = nil
        showAlert(title: AlertMessages.noOrderNoMessage.title, subtitle: AlertMessages.noOrderNoMessage.subtitle)
    }
    
    internal func quitDeviceOrder() {
        BLEManager.shared.write(message: "QUIT")
    }
    
    func continueOrder() {
        isCreatingOrder = true
        placeOrder(spiceLevels: [])
    }
    
    internal func updateView() {
    }
    
    func placeOrder(spiceLevels: [Int]) {
        
    }
    
}

extension OrderViewController: BLEManagerDelegate {
    func manager(_ manager: BLEManager, didReceive message: String, error: Error?) {
        guard isCreatingOrder else {
            return
        }
        
        messageTimer?.invalidate()
        
        if message.contains("OK") {
            let spiceLevels = Helpers.parseLevels(string: message)
            
            placeOrder(spiceLevels: spiceLevels)
            return
        }
        
        if message.contains("INPR") {
            isCreatingOrder = false
            let action = AlertAction(title: "Yes", action: checkDeviceStatus, color: Colors.maroon)
            showAlert(title: AlertMessages.noOrderInpr.title, subtitle: AlertMessages.noOrderInpr.subtitle, actions: [action], closeTitle: "Cancel")
            return
        }
        
        if message.contains("BUSY") {
            isCreatingOrder = false
            let action = AlertAction(title: "Yes", action: quitDeviceOrder, color: Colors.maroon)
            showAlert(title: AlertMessages.noOrderBusy.title, subtitle: AlertMessages.noOrderBusy.subtitle, actions: [action], closeTitle: "Cancel")
            return
        }
        
    }
}
