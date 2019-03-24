import UIKit
import QSpiceKit

class RecipeOrderViewController: OrderViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        loadRecipes()
        
        title = "Recipe Order"
        
        tableView.register(RecipeCell.self, forCellReuseIdentifier: RecipeCell.reuseId)
        tableView.delegate = self
        tableView.dataSource = self
        
        setupSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
    override func placeOrder(spiceLevels: [Int]) {
        do {
            try controller.createRecipeOrder(spiceLevels: spiceLevels)
            dismiss(animated: true)
        } catch OrderError.notConnected {
            isCreatingOrder = false
            showAlert(title: AlertMessages.noOrderBleConnect.title, subtitle: AlertMessages.noOrderBleConnect.subtitle)
        } catch OrderError.lowLevel(let levels) {
            isCreatingOrder = false
            let action = AlertAction(title: "Continue", action: continueOrder, color: Colors.maroon)
            showAlert(title: AlertMessages.spiceLevels.title, subtitle: "\(AlertMessages.spiceLevels.subtitle) \(levels)", actions: [action], closeTitle: "Cancel")
        } catch OrderError.noSpices {
            isCreatingOrder = false
            showAlert(title: AlertMessages.noOrderNoSpices.title, subtitle: AlertMessages.noOrderNoSpices.subtitle)
        } catch OrderError.missingSpices {
            isCreatingOrder = false
            showAlert(title: AlertMessages.noOrderMissingSpices.title, subtitle: AlertMessages.noOrderMissingSpices.subtitle)
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
        if controller.order.recipe != nil {
            placeOrderButton.isEnabled = true
        } else {
            placeOrderButton.isEnabled = false
        }
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
