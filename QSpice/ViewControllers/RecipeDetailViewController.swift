import UIKit
import SnapKit

class RecipeDetailViewController: UIViewController {
    
    enum RecipeDetailMode {
        case view
        case edit
        case new
    }
    
    private(set) var controller: RecipeDetailController
    
    private var linkText: String = ""
    private var contentText: String = ""
    private var imageChanged = false
    
    var mode: RecipeDetailMode = .edit
    
    init(controller: RecipeDetailController) {
        self.controller = controller
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChangedFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        recipeNameTextField.text = controller.recipeDetail.name
        linkText = controller.recipeDetail.link ?? ""
        contentText = controller.recipeDetail.content ?? ""
        if let imageData = controller.recipeDetail.image {
            recipeImageView.image = UIImage(data: imageData, scale: UIScreen.main.scale)
        }
        
        prepareView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .white
    }

    // MARK: Gesture Recognizers

    @objc func completeRecipeTapped() {
        let name = recipeNameTextField.text ?? ""
        
        do {
            if mode == .new {
                try controller.addRecipe(name: name, link: linkText, content: contentText, image: imageChanged ? recipeImageView.image?.jpegData(compressionQuality: 0.75) : nil)
                
            } else {
                try controller.updateRecipe(name: name, link: linkText, content: contentText, image: imageChanged ? recipeImageView.image?.jpegData(compressionQuality: 0.75) : nil)
            }
            
            imageChanged = false
            mode = .view
            setupStyling()
            tableView.setContentOffset(.zero, animated: true)
            tableView.reloadData()
            
        } catch RecipeError.invalidName {
            showAlert(title: AlertMessages.invalidName.title, subtitle: AlertMessages.invalidName.subtitle)
        } catch {
            print("Error: ", error.localizedDescription)
        }
    }
    
    @objc func recipeImageTapped() {
        let mediaPicker = MediaPickerViewController()
        mediaPicker.pickerDelegate = self
        mediaPicker.modalPresentationStyle = .custom
        
        present(mediaPicker, animated: true, completion: nil)
    }
    
    @objc func editRecipeTapped() {
        mode = .edit
        setupStyling()
        tableView.reloadData()
    }
    
    // MARK: View Management
    
    var doneButtonBottomConstraint: Constraint!
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(LinkCell.self, forCellReuseIdentifier: LinkCell.reuseId)
        tableView.register(RecipeDescCell.self, forCellReuseIdentifier: RecipeDescCell.reuseId)
        tableView.register(SpiceCell.self, forCellReuseIdentifier: SpiceCell.reuseId)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.tableFooterView = UIView()
        
        return tableView
    }()
    
    private let recipeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.darkGrey.withAlphaComponent(0.6)
        
        return view
    }()
    
    private let doneButton: ActionButton = {
        let button = ActionButton()
        button.setTitle("Done", for: .normal)
        
        return button
    }()
    
    private let recipeNameTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Recipe name...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.darkened()])
        textField.tintColor = Colors.darkGrey
        textField.font = Fonts.cStdBold?.withSize(24.0)
        textField.textColor = .white
        return textField
    }()

    private func prepareView() {
        view.backgroundColor = .white
        
        let gesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        gesture.cancelsTouchesInView = false
        view.addGestureRecognizer(gesture)
        
        doneButton.addTarget(self, action: #selector(completeRecipeTapped), for: .touchUpInside)
        
        view.addSubview(recipeImageView)
        view.addSubview(dimView)
        view.addSubview(recipeNameTextField)
        view.addSubview(tableView)
        view.addSubview(doneButton)
        
        recipeImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.30)
        }
        
        dimView.snp.makeConstraints { make in
            make.edges.equalTo(recipeImageView.snp.edges)
        }
        
        recipeNameTextField.snp.makeConstraints { make in
            make.bottom.equalTo(dimView.snp.bottom).offset(-16)
            make.leading.equalTo(dimView.snp.leading).offset(16)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(dimView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(doneButton.snp.top).offset(-8)
        }
        
        doneButton.snp.makeConstraints { make in
            doneButtonBottomConstraint = make.bottom.equalTo(view.snp.bottomMargin).offset(-8).constraint
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(40.0)
        }
        
        setupStyling()
    }
    
    private func setupStyling() {
        switch mode {
        case .edit, .new:
            recipeNameTextField.isEnabled = true
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "camera"), style: .plain, target: self, action: #selector(recipeImageTapped))
            
            doneButtonBottomConstraint.update(offset: -8)

        case .view:
            recipeNameTextField.isEnabled = false
            
            doneButtonBottomConstraint.update(offset: 48.0)
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "pencil"), style: .plain, target: self, action: #selector(editRecipeTapped))
        }
        
        if mode == .edit {
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
        
    }
    
    @objc func keyboardChangedFrame(notification: Notification) {
        guard let textView = (tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? RecipeDescCell)?.descriptionTextView else {
            return
        }
        
        if textView.isFirstResponder {
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                var insets = UIEdgeInsets.zero
                insets.bottom = min(tableView.frame.height - textView.frame.height, keyboardFrame.height)
                tableView.contentInset = insets
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        tableView.contentInset = .zero
    }
    
}

// MARK: UITableView Delegate & Data Source

extension RecipeDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < 2 {
            return 1
        }
        
        switch mode {
        case .edit, .new:
            return AppConfig.maxNumberOfActiveSpices
        case .view:
            return controller.recipeDetail.ingredients.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: LinkCell.reuseId, for: indexPath) as! LinkCell
            
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: cell.bounds.width * 2, bottom: 0.0, right: 0.0)
            cell.mode = mode
            cell.linkTextField.delegate = self
            cell.linkTextField.text = mode == .edit ? linkText : controller.recipeDetail.link ?? "-"
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: RecipeDescCell.reuseId, for: indexPath) as! RecipeDescCell
            
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: cell.bounds.width * 2, bottom: 0.0, right: 0.0)
            cell.mode = mode
            cell.descriptionTextView.delegate = self
            cell.descriptionTextView.text = mode == .edit ? contentText : controller.recipeDetail.content ?? "-"
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: SpiceCell.reuseId, for: indexPath) as! SpiceCell
            
            if let ingredient = controller.recipeDetail.ingredients[indexPath.row + 1] {
                if mode == .edit || mode == .new {
                    cell.type = .ingredientEditable
                } else {
                    cell.type = .ingredient
                }
                
                cell.delegate = self
                cell.color = UIColor(hexString: ingredient.spice.color)
                cell.spiceNameLabel.text = ingredient.spice.name
                cell.weight = "\(ingredient.spice.weight)"
                cell.amount = ingredient.amount
                cell.metric = ingredient.metric
            } else {
                cell.type = .unselected
            }
            
            return cell
            
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            let destination = SpiceSelectionViewController(controller: SpiceSelectionController(spiceService: SpiceService(context: controller.recipeService.context)))
            destination.spiceNumber = indexPath.row + 1
            destination.delegate = self
            
            navigationController?.pushViewController(destination, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return mode == .view ? nil : indexPath
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let clearAction = UIContextualAction(style: .destructive, title: "Clear") { [weak self] (_, _, completion) in
            self?.controller.removeIngredient(for: indexPath.row + 1)
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            
            completion(false)
        }
        
        clearAction.image = UIImage(named: "erase")
        clearAction.backgroundColor = Colors.lightGrey.lighter()
        
        let config = UISwipeActionsConfiguration(actions: [clearAction])
        
        return config
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section > 1 && controller.recipeDetail.ingredients[indexPath.row + 1] != nil && mode != .view
    }
    
}

// MARK: Media Picker Delegate

extension RecipeDetailViewController: MediaPickerDelegate {
    func mediaPicker(_ mediaPicker: MediaPickerViewController, didFinishPicking media: UIImage?) {
        dismiss(animated: true, completion: nil)
        
        imageChanged = true
        recipeImageView.image = media
    }
}

// MARK: Spice Selection Delegate

extension RecipeDetailViewController: SpiceSelectionDelegate {
    func didSelect(spice: Spice, for slot: Int) {
        controller.addIngredient(spice, for: slot)
        tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
        
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: Spice Cell Delegate

extension RecipeDetailViewController: SpiceCellDelegate {
    func spiceCellDidChangeMetric(cell: SpiceCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        if cell.metric == "tsp" {
            cell.metric = "tbsp"
        } else {
            cell.metric = "tsp"
        }
        
        controller.updateIngredient(amount: cell.amount, metric: cell.metric, for: indexPath.row + 1)
    }
    
    func spiceCellDidIncrement(cell: SpiceCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        cell.amount = Spice.nextAmount(after: cell.amount, increment: true)
        controller.updateIngredient(amount: cell.amount, metric: cell.metric, for: indexPath.row + 1)
    }
    
    func spiceCellDidDecrement(cell: SpiceCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        cell.amount = Spice.nextAmount(after: cell.amount, increment: false)
        controller.updateIngredient(amount: cell.amount, metric: cell.metric, for: indexPath.row + 1)
    }
    
}

// MARK: UITextView Delegate

extension RecipeDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let prevHeight = textView.frame.height
        UIView.setAnimationsEnabled(false)
        textView.sizeToFit()
        
        if prevHeight != textView.frame.height {
            
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            tableView.contentOffset.y += textView.frame.height - prevHeight
        }
        UIView.setAnimationsEnabled(true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        contentText = textView.text
    }
}

// MARK: UITextFieldDelegate

extension RecipeDetailViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        linkText = textField.text ?? ""
    }
}
