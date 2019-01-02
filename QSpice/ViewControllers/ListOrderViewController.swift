import UIKit

class ListOrderViewController: UIViewController {

    var controller: OrderController
    
    init(controller: OrderController) {
        self.controller = controller
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    let quantityView = QuantityView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "List Order"
        
        view.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.prefersLargeTitles = true
        let titleAttributes = [NSAttributedString.Key.foregroundColor: Colors.darkGrey]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        navigationController?.navigationBar.largeTitleTextAttributes = titleAttributes
        navigationController?.navigationBar.tintColor = Colors.lightGrey
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "cross"), style: .plain, target: self, action: #selector(cancelOrder))
        
        placeOrderButton.addTarget(self, action: #selector(placeOrderTapped), for: .touchUpInside)
        
        tableView.register(SpiceCell.self, forCellReuseIdentifier: SpiceCell.reuseId)
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.contentInset = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.delegate = self
        tableView.dataSource = self
        
        quantityView.amountView.incrementButton.addTarget(self, action: #selector(incrementQuantity), for: .touchUpInside)
        quantityView.amountView.decrementButton.addTarget(self, action: #selector(decrementQuantity), for: .touchUpInside)
        
        setupSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        controller.clearOrder()
        
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
    
    @objc func placeOrderTapped() {
        do {
            try controller.createListOrder()
        } catch {
            print("Could not create list order: ", error.localizedDescription)
        }
    }
    
    @objc func cancelOrder() {
        dismiss(animated: true)
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
    
    private func updateView() {
        if controller.isValidListOrder() {
            placeOrderButton.isEnabled = true
        } else {
            placeOrderButton.isEnabled = false
        }
    }
    
    @objc func incrementQuantity() {
        quantityView.amountView.amount = controller.updateOrder(quantity: 1)
    }
    
    @objc func decrementQuantity() {
        quantityView.amountView.amount = controller.updateOrder(quantity: -1)
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
        cell.amount = ingredient.amount
        cell.metric = ingredient.metric
        
        return cell
    }
    
}

extension ListOrderViewController: SpiceCellDelegate {
    func spiceCellDidChangeMetric(cell: SpiceCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        if cell.metric == "tsp" {
            cell.metric = "tbsp"
        } else {
            cell.metric = "tsp"
        }
        
        controller.updateIngredient(amount: cell.amount, metric: cell.metric, for: indexPath.row)
    }
    
    func spiceCellDidIncrement(cell: SpiceCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        cell.amount = Spice.nextAmount(after: cell.amount, increment: true, allowZero: true)
        controller.updateIngredient(amount: cell.amount, metric: cell.metric, for: indexPath.row)
        updateView()
    }
    
    func spiceCellDidDecrement(cell: SpiceCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        cell.amount = Spice.nextAmount(after: cell.amount, increment: false, allowZero: true)
        controller.updateIngredient(amount: cell.amount, metric: cell.metric, for: indexPath.row)
        updateView()
    }
}
