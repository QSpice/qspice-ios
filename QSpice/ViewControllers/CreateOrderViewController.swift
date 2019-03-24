import UIKit
import Instructions

class CreateOrderViewController: UIViewController {

    var controller: OrderController
    let coachController = CoachMarksController()
    var messageTimer: Timer?
    
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
    
    let cancelOrderButton: ActionButton = {
        let button = ActionButton()
        button.setTitle("Cancel Order", for: .normal)
        button.labelText = "Cancel Order"
        button.isHidden = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        listOrderView.addTarget(target: self, action: #selector(orderFromListTapped), for: .touchUpInside)
        recipeOrderView.addTarget(target: self, action: #selector(orderFromRecipeTapped), for: .touchUpInside)
        cancelOrderButton.addTarget(self, action: #selector(cancelOrder), for: .touchUpInside)
        coachController.dataSource = self
        coachController.delegate = self
        
        setupSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        coachController.stop(immediately: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        BLEManager.shared.delegate = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            BLEManager.shared.write(message: "POLL")
        }
        
        if UserDefaults.standard.string(forKey: HintMessages.keys["CreateOrder"]!) == nil {
            coachController.start(in: .window(over: self))
        }
    }
    
    @objc func orderFromListTapped() {
        let destination = QSNavigationController(rootViewController: ListOrderViewController(controller: controller))
        
        present(destination, animated: true)
    }
    
    @objc func orderFromRecipeTapped() {
        let destination = QSNavigationController(rootViewController: RecipeOrderViewController(controller: controller))
        
        present(destination, animated: true)
    }
    
    @objc func cancelOrder() {
        cancelOrderButton.isLoading = true
        messageTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(messageTimeout), userInfo: nil, repeats: false)
        
        if BLEManager.shared.isReady {
            BLEManager.shared.write(message: "QUIT")
        }
    }
        
    @objc func messageTimeout() {
        messageTimer = nil
        cancelOrderButton.isLoading = false
        showAlert(title: AlertMessages.couldNotCancel.title, subtitle: AlertMessages.couldNotCancel.subtitle)
    }
    
    private func setupSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(stackView)
        view.addSubview(cancelOrderButton)
        
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
            make.bottom.equalTo(stackView.snp.top).offset(-64)
            make.centerX.equalToSuperview()
        }
        
        cancelOrderButton.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(64)
            make.centerX.equalToSuperview()
            make.leading.equalTo(stackView.snp.leading).offset(16)
            make.trailing.equalTo(stackView.snp.trailing).offset(-16)
        }
        
        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(32.0)
            make.trailing.greaterThanOrEqualToSuperview().offset(-32.0)
            make.centerX.equalToSuperview()
        }
    }

}

extension CreateOrderViewController: CoachMarksControllerDataSource {
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        
        let coachBodyView = QSCoachMarkBodyView()
        coachBodyView.hintLabel.text = HintMessages.createOrderPage[index]
        
        coachBodyView.nextButton.setTitle("OK", for: .normal)
        
        return (bodyView: coachBodyView, arrowView: coachViews.arrowView)
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 2
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        
        var coachMark: CoachMark = coachMarksController.helper.makeCoachMark()
        
        switch index {
        case 0:
            coachMark = coachMarksController.helper.makeCoachMark(for: listOrderView)

        case 1:
            coachMark = coachMarksController.helper.makeCoachMark(for: recipeOrderView)
        default:
            break
        }
        
        return coachMark
    }
}

extension CreateOrderViewController: CoachMarksControllerDelegate {
    func coachMarksController(_ coachMarksController: CoachMarksController, didEndShowingBySkipping skipped: Bool) {
        UserDefaults.standard.set(true, forKey: HintMessages.keys["CreateOrder"]!)
    }
}

extension CreateOrderViewController: BLEManagerDelegate {
    func manager(_ manager: BLEManager, didReceive message: String, error: Error?) {
        
        messageTimer?.invalidate()
        
        if message.contains("OK") {
            cancelOrderButton.isLoading = false
            cancelOrderButton.isHidden = true
            return
        }
        
        if message.contains("BUSY") {
            cancelOrderButton.isHidden = false
        }
        
    }
}
