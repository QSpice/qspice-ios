import UIKit

class RecipesViewController: UITableViewController {

    private(set) var controller: RecipeController
    
    init(controller: RecipeController) {
        self.controller = controller
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadRecipes()
        tableView.reloadData()
        updateView()
        
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.tintColor = UIColor(r: 77.0, g: 77.0, b: 77.0, a: 1.0)
    }
    
    private func loadRecipes() {
        do {
            try controller.recipesFetchedResults.performFetch()
        } catch {
            showAlert(title: AlertMessages.loadRecipes.title, subtitle: AlertMessages.loadRecipes.subtitle)
        }
    }

    // MARK: - UITableView Delegate & Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return controller.recipesFetchedResults.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.recipesFetchedResults.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RecipeCell.reuseId, for: indexPath) as! RecipeCell
        
        let recipe = controller.recipesFetchedResults.object(at: indexPath)
        
        cell.recipeNameLabel.text = recipe.name
        cell.recipeImage = UIImage.load(image: recipe.uuid.uuidString)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? RecipeCell else {
            return
        }
        
        let recipe = controller.recipesFetchedResults.object(at: indexPath)
        
        var i: Int = 0
        
        let ingredients: [Int: IngredientDetail]? = recipe.ingredients?.reduce(into: [:]) { ingredients, ingredient in
            i += 1
            if let ingredient = ingredient as? Ingredient {
                ingredients?[i] = IngredientDetail(spice: ingredient.spice, amount: ingredient.amount, metric: ingredient.metric)
            }
        }
        
        let recipeDetail = RecipeDetail(image: cell.recipeImage?.jpegData(compressionQuality: 1.0), name: recipe.name, link: recipe.link, content: recipe.content, ingredients: ingredients ?? [:], uuid: recipe.uuid, objectID: recipe.objectID)
        
        let destinationController = RecipeDetailController(recipeService: controller.recipeService, recipeDetail: recipeDetail)
        let destination = RecipeDetailViewController(controller: destinationController)
        destination.mode = .view
        
        navigationController?.pushViewController(destination, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let recipe = controller.recipesFetchedResults.object(at: indexPath)
        
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { [weak self] (_, _, completion) in
            do {
                try self?.controller.deleteRecipe(recipe: recipe)
                completion(true)
                self?.loadRecipes()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self?.updateView()
            } catch {
                completion(false)
            }
        }
        
        deleteAction.backgroundColor = UIColor.red
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return config
    }
    
    // MARK: Gesture Recognizers
    
    @objc func addRecipeTapped() {
        let recipeDetailViewController = RecipeDetailViewController(controller: RecipeDetailController(recipeService: controller.recipeService))
        recipeDetailViewController.mode = .new
        
        navigationController?.pushViewController(recipeDetailViewController, animated: true)
    }
    
    // MARK: View Management
    
    private func updateView() {
        let rowCount = controller.recipesFetchedResults.sections?.first?.numberOfObjects ?? 0
        
        if rowCount > 0 {
            tableView.backgroundView = nil
        } else {
            tableView.backgroundView = {
                let label = UILabel(frame: view.frame)
                label.textAlignment = .center
                label.text = "No Recipes."
                
                return label
            }()
            
        }
    }
    
    private func prepareView() {
        title = navigationController?.tabBarItem.title
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRecipeTapped))
        
        tableView.register(RecipeCell.self, forCellReuseIdentifier: RecipeCell.reuseId)
        tableView.contentInset = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
    }

}
