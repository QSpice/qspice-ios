import UIKit

class ListOrderViewController: OrderViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "List Order"
        
        tableView.register(SpiceCell.self, forCellReuseIdentifier: SpiceCell.reuseId)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.alwaysBounceVertical = false
        
        setupSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if controller.activeSpices.count < 1 {
            placeOrderButton.isEnabled = false
            tableView.backgroundView = {
                let label = UILabel(frame: view.frame)
                label.textAlignment = .center
                label.text = "No Active Spices."
                label.textColor = Colors.lightGrey
                
                return label
            }()
        }
        
        updateView()
    }
    
    override func placeOrder(spiceLevels: [Int]) {
        do {
            try controller.createListOrder(spiceLevels: spiceLevels)
            dismiss(animated: true)
        } catch OrderError.notConnected {
            isCreatingOrder = false
            showAlert(title: AlertMessages.noOrderBleConnect.title, subtitle: AlertMessages.noOrderBleConnect.subtitle)
        } catch OrderError.lowLevel(let levels) {
            isCreatingOrder = false
            let action = AlertAction(title: "Continue", action: continueOrder, color: Colors.maroon)
            showAlert(title: AlertMessages.spiceLevels.title, subtitle: "\(AlertMessages.spiceLevels.subtitle) \(levels)", actions: [action], closeTitle: "Cancel")
        } catch OrderError.exceededAmount {
            isCreatingOrder = false
            showAlert(title: AlertMessages.noOrderExceededAmount.title, subtitle: AlertMessages.noOrderExceededAmount.subtitle)
        } catch {}
    }
    
    private func setupSubviews() {
        view.addSubview(tableView)
        view.addSubview(placeOrderButton)
        view.addSubview(quantityView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(quantityView.snp.top)
        }
        
        placeOrderButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin).offset(-16)
            make.leading.equalToSuperview().offset(16.0)
            make.trailing.equalToSuperview().offset(-16.0)
            make.height.equalTo(40.0)
        }
        
        quantityView.snp.makeConstraints { make in
            make.bottom.equalTo(placeOrderButton.snp.top).offset(-16)
            make.leading.trailing.equalToSuperview().offset(16.0)
        }
    }
    
    override func updateView() {
        if controller.isValidListOrder() {
            placeOrderButton.isEnabled = true
        } else {
            placeOrderButton.isEnabled = false
        }
    }

}

extension ListOrderViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.activeSpices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SpiceCell.reuseId, for: indexPath) as! SpiceCell
        
        let ingredient = controller.order.orderItems[indexPath.row].ingredient

        cell.delegate = self
        cell.type = .ingredientEditable
        cell.spiceNameLabel.text = ingredient.spice.name
        cell.color = UIColor(hexString: ingredient.spice.color)
        cell.weight = "\(ingredient.spice.weight)"
        cell.quantity = ingredient.quantity
        cell.metric = ingredient.metric
        
        return cell
    }
    
}

extension ListOrderViewController: SpiceCellDelegate {
    func spiceCell(cell: SpiceCell, didChange quantity: Int) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        controller.updateIngredient(quantity: quantity, for: indexPath.row)
        updateView()
    }
    
    func spiceCell(cell: SpiceCell, didChange metric: Metric) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        controller.updateIngredient(metric: metric, for: indexPath.row)
    }
}
