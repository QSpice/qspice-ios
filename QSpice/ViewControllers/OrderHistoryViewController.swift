import UIKit
import QSpiceKit

class OrderHistoryViewController: UITableViewController {

    var controller: OrderController
    
    init(controller: OrderController) {
        self.controller = controller
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = navigationController?.tabBarItem.title
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = .white
        let titleAttributes = [NSAttributedString.Key.foregroundColor: Colors.darkGrey]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        navigationController?.navigationBar.largeTitleTextAttributes = titleAttributes
        
        tableView.register(OrderCell.self, forCellReuseIdentifier: OrderCell.reuseId)
        tableView.contentInset = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 40
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadOrders()
        tableView.reloadData()
        
        let rowCount = controller.ordersFetchedResults.sections?.first?.numberOfObjects ?? 0
        
        if rowCount > 0 {
            tableView.backgroundView = nil
        } else {
            tableView.backgroundView = {
                let label = UILabel(frame: view.frame)
                label.textAlignment = .center
                label.text = "No Orders."
                
                return label
            }()
            
        }
    }
    
    private func loadOrders() {
        do {
            try controller.ordersFetchedResults.performFetch()
        } catch {
            print("Could not load orders: ", error.localizedDescription)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return controller.ordersFetchedResults.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return controller.ordersFetchedResults.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OrderCell.reuseId, for: indexPath) as! OrderCell
        
        let order = controller.ordersFetchedResults.object(at: indexPath)
        
        cell.dateLabel.text = dateFormatter.string(from: order.date)
        
        cell.setupFromOrder(order)
        
        return cell
    }

}
