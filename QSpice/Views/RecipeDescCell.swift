import UIKit
import UITextView_Placeholder

class RecipeDescCell: UITableViewCell {

    static let reuseId = "RecipeDescCell"
    
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
        label.text = "Recipe"
        return label
    }()
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.placeholder = "Paste recipe here..."
        textView.tintColor = Colors.darkGrey
        textView.font = Fonts.cStdBook?.withSize(16.0)
        textView.textColor = Colors.lightGrey
        textView.isScrollEnabled = false
        textView.textContainer.lineFragmentPadding = 0.0
        return textView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupSubviews()
    }
    
    private func setupSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionTextView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.leading.equalTo(titleLabel.snp.leading)
            make.bottom.equalToSuperview().offset(-16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        descriptionTextView.sizeToFit()
        
        setupStyling()
    }
    
    private func setupStyling() {
        switch mode {
        case .edit, .new:
            descriptionTextView.isEditable = true
        case .view:
            descriptionTextView.isEditable = false
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
