import UIKit

class CreateOrderViewController: UIViewController {

    var controller: OrderController
    
    init(controller: OrderController) {
        self.controller = controller
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create an Order"
        label.font = Fonts.cStdBold?.withSize(34.0)
        label.textColor = Colors.darkGrey
        return label
    }()
    
    let listOrderView: OrderSelectionView = {
        let view = OrderSelectionView()
        view.labelText = "From a List"
        view.color = Colors.maroon
        view.image = UIImage(named: "list_order")
        return view
    }()
    
    let recipeOrderView: OrderSelectionView = {
        let view = OrderSelectionView()
        view.labelText = "From a Recipe"
        view.color = Colors.maroon
        view.image = UIImage(named: "recipe_order")
        
        return view
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        listOrderView.addTarget(target: self, action: #selector(orderFromListTapped), for: .touchUpInside)
        recipeOrderView.addTarget(target: self, action: #selector(orderFromRecipeTapped), for: .touchUpInside)
        
        setupSubviews()
    }
    
    @objc func orderFromListTapped() {
        let destination = QSNavigationController(rootViewController: ListOrderViewController(controller: controller))
        
        present(destination, animated: true)
    }
    
    @objc func orderFromRecipeTapped() {
        let destination = QSNavigationController(rootViewController: RecipeOrderViewController(controller: controller))
        
        present(destination, animated: true)
    }
    
    private func setupSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(listOrderView)
        stackView.addArrangedSubview({
            let label = UILabel()
            label.font = Fonts.cStdMedium
            label.text = "OR"
            label.textAlignment = .center
            return label
        }())
        stackView.addArrangedSubview(recipeOrderView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(64.0)
            make.centerX.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(48.0)
            make.leading.greaterThanOrEqualToSuperview().offset(32.0)
            make.trailing.greaterThanOrEqualToSuperview().offset(-32.0)
            make.centerX.equalToSuperview()
        }
    }

}
