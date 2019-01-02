import UIKit

class RecipeOrderViewController: UIViewController {

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
        button.isEnabled = false
        return button
    }()
    
    let quantityView = QuantityView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadRecipes()
        
        title = "Recipe Order"
        
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
        
        tableView.register(RecipeCell.self, forCellReuseIdentifier: RecipeCell.reuseId)
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
        
        if controller.recipesFetchedResults.fetchedObjects?.count ?? 0 < 1 {
            placeOrderButton.isEnabled = false
            tableView.backgroundView = {
                let label = UILabel(frame: view.frame)
                label.textAlignment = .center
                label.text = "No Recipes"
                label.textColor = Colors.lightGrey
                
                return label
            }()
        }
        
        updateView()
    }
    
    private func loadRecipes() {
        do {
            try controller.recipesFetchedResults.performFetch()
        } catch {
            print("Could not load spices: ", error.localizedDescription)
        }
    }
    
    @objc func placeOrderTapped() {
        do {
            try controller.createRecipeOrder()
        } catch {
            print("Could not create order: ", error.localizedDescription)
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
        if controller.order.recipe != nil {
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

extension RecipeOrderViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.recipesFetchedResults.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RecipeCell.reuseId, for: indexPath) as! RecipeCell
        
        let recipe = controller.recipesFetchedResults.object(at: indexPath)
        
        cell.recipeNameLabel.text = recipe.name
        cell.recipeImage = UIImage.load(image: recipe.uuid.uuidString)
        cell.isChosen = false
        cell.contentView.alpha = 1.0
        
        if let selectedRecipe = controller.order.recipe {
            if recipe.uuid != selectedRecipe.uuid {
                cell.contentView.alpha = 0.5
            } else {
                cell.isChosen = true
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recipe = controller.recipesFetchedResults.object(at: indexPath)
        
        controller.selectRecipe(recipe)
        tableView.reloadData()
        updateView()
    }
    
}
