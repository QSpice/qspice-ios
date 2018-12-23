//
//  RecipeDetailViewController.swift
//  QSpice
//
//  Created by Anthony Fiorito on 2018-12-22.
//  Copyright © 2018 Anthony Fiorito. All rights reserved.
//

import UIKit

class RecipeDetailViewController: UIViewController {

    let sectionTitles = ["Link", "Recipe", "Spices"]
    
    enum RecipeDetailMode {
        case view
        case edit
    }
    
    var mode: RecipeDetailMode = .edit
    
    let tableView: UITableView = {
        let tableView = UITableView()

        return tableView
    }()
    
    let recipeImageView: UIImageView = {
        let imageView = UIImageView()

        return imageView
    }()
    
    let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.darkGrey.withAlphaComponent(0.6)
        
        return view
    }()
    
    let cameraImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.image = UIImage(named: "camera")
        
        return imageView
    }()
    
    let recipeNameTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Recipe name...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.darkened()])
        textField.tintColor = Colors.darkGrey
        textField.font = Fonts.cStdBold?.withSize(24.0)
        textField.textColor = .white
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .white
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.register(LinkCell.self, forCellReuseIdentifier: LinkCell.reuseId)
        tableView.register(RecipeDescCell.self, forCellReuseIdentifier: RecipeDescCell.reuseId)
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChangedFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setupSubviews()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupSubviews() {
        view.addSubview(recipeImageView)
        view.addSubview(dimView)
        view.addSubview(recipeNameTextField)
        view.addSubview(tableView)
        
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
            make.bottom.equalToSuperview()
        }
        
        setupStyling()
    }
    
    private func setupStyling() {
        switch mode {
        case .edit:
            recipeNameTextField.isEnabled = true
            dimView.addSubview(cameraImageView)
            
            cameraImageView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.height.equalTo(60.0*0.8125)
                make.width.equalTo(60)
            }
            
        case .view:
            recipeNameTextField.isEnabled = false
        }
        
    }
    
}

extension RecipeDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < 2 {
            return 1
        }
        
        switch mode {
        case .edit:
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
            switch mode {
            case .edit:
                break
            case .view:
                break
            }
            
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    @objc func keyboardChangedFrame(notification: Notification) {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? RecipeDescCell
        guard let textView = cell?.descriptionTextView else {
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
