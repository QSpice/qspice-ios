import UIKit
import SnapKit

class RecipeCell: UITableViewCell {
    
    static let reuseId = "RecipeCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupSubviews()
    }
    
    var recipeImage: UIImage? {
        didSet {
            if recipeImage != nil {
                recipeImageView.snp.remakeConstraints { make in
                    make.leading.top.bottom.equalToSuperview()
                    make.height.equalTo(recipeImageView.snp.width)
                    make.width.equalTo(contentView.snp.height)
                }
                recipeImageView.image = recipeImage
            }
        }
    }
    
    private let recipeImageView: NoIntrinsicSizeImageView = {
        let view = NoIntrinsicSizeImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        
        return view
    }()
    
    let recipeNameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.cStdMedium?.withSize(20.0)
        label.textColor = Colors.darkGrey
        
        return label
    }()
    
    private func setupSubviews() {
        contentView.addSubview(recipeImageView)
        contentView.addSubview(recipeNameLabel)
        
        recipeImageView.snp.makeConstraints { (make) in
            make.leading.top.equalToSuperview()
            make.height.equalTo(recipeImageView.snp.width)
            make.width.equalTo(0.0)
        }
        
        recipeNameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.leading.equalTo(recipeImageView.snp.trailing).offset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
    }

}
