import UIKit

class RecipeDetailViewController: UIViewController {

    let sectionTitles = ["Link", "Recipe", "Spices"]
    
    enum RecipeDetailMode {
        case view
        case edit
        case new
    }
    
    var mode: RecipeDetailMode = .edit
    
    var controller: RecipeDetailController
    
    let tableView: UITableView = {
        let tableView = UITableView()

        return tableView
    }()
    
    let recipeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill

        return imageView
    }()
    
    let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.darkGrey.withAlphaComponent(0.6)
        
        return view
    }()
    
    let doneButton: ActionButton = {
        let button = ActionButton()
        button.setTitle("Done", for: .normal)
        
        return button
    }()
    
    let recipeNameTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Recipe name...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.darkened()])
        textField.tintColor = Colors.darkGrey
        textField.font = Fonts.cStdBold?.withSize(24.0)
        textField.textColor = .white
        return textField
    }()
    
    var recipeContentTextView: UITextView? {
        return (tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? RecipeDescCell)?.descriptionTextView
    }
    
    var recipeLinkTextField: UITextField? {
        return (tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? LinkCell)?.linkTextField
    }
    
    init(controller: RecipeDetailController) {
        self.controller = controller
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        view.backgroundColor = .white
        let gesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        gesture.cancelsTouchesInView = false
        view.addGestureRecognizer(gesture)
        
        doneButton.addTarget(self, action: #selector(completeRecipeTapped), for: .touchUpInside)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.register(LinkCell.self, forCellReuseIdentifier: LinkCell.reuseId)
        tableView.register(RecipeDescCell.self, forCellReuseIdentifier: RecipeDescCell.reuseId)
        tableView.register(SpiceCell.self, forCellReuseIdentifier: SpiceCell.reuseId)
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChangedFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setupSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc func completeRecipeTapped() {
        let name = recipeNameTextField.text ?? ""
        let link = recipeLinkTextField?.text ?? ""
        let content = recipeContentTextView?.text ?? ""
        
        do {
            if mode == .new {
                try controller.addRecipe(name: name, link: link, content: content, image: nil)
            } else {
                try controller.updateRecipe(name: name, link: link, content: content, image: nil)
            }
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupSubviews() {
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
            make.bottom.equalTo(view.snp.bottomMargin).offset(-8)
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
            
            
            
        case .view:
            recipeNameTextField.isEnabled = false
        }
        
    }
    
    @objc func keyboardChangedFrame(notification: Notification) {
        guard let textView = recipeContentTextView else {
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
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: LinkCell.reuseId, for: indexPath) as! LinkCell
            
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: cell.bounds.width * 2, bottom: 0.0, right: 0.0)
            cell.mode = mode
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: RecipeDescCell.reuseId, for: indexPath) as! RecipeDescCell
            
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: cell.bounds.width * 2, bottom: 0.0, right: 0.0)
            cell.mode = mode
            cell.descriptionTextView.delegate = self
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: SpiceCell.reuseId, for: indexPath) as! SpiceCell
            
            if let spice = controller.recipeDetail.spices[indexPath.row + 1] {
                cell.type = .display
                cell.color = UIColor(hexString: spice.color)
                cell.spiceNameLabel.text = spice.name
                cell.weight = "\(spice.weight)"
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
    
}

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
}

extension RecipeDetailViewController: MediaPickerDelegate {
    func mediaPicker(_ mediaPicker: MediaPickerViewController, didFinishPicking media: UIImage?) {
        dismiss(animated: true, completion: nil)
        
        recipeImageView.image = media
    }
}

extension RecipeDetailViewController: SpiceSelectionDelegate {
    func didSelect(spice: Spice, for slot: Int) {
        controller.addSpice(spice, for: slot)
        tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
        
        navigationController?.popViewController(animated: true)
    }
    
}
