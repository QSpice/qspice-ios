import UIKit

class LinkCell: UITableViewCell {

    static let reuseId = "LinkCell"
    
    var mode: RecipeDetailViewController.RecipeDetailMode = .edit
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        setupSubviews()
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.cStdMedium?.withSize(20.0)
        label.textColor = Colors.darkGrey
        label.text = "Link"
        return label
    }()
    
    let linkTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Recipe website link..."
        textField.tintColor = Colors.darkGrey
        textField.font = Fonts.cStdBook
        textField.textColor = Colors.lightGrey
        return textField
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupSubviews()
    }
    
    private func setupSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(linkTextField)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        linkTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.leading.equalTo(titleLabel.snp.leading)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        setupStyling()
    }
    
    private func setupStyling() {
        switch mode {
        case .edit, .new:
            linkTextField.isEnabled = true
        case .view:
            linkTextField.isEnabled = false
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
