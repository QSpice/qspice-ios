import UIKit
import QSpiceKit

class QuantityView: UIView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Quantity"
        label.font = Fonts.cStdBook?.withSize(20.0)
        label.textColor = Colors.darkGrey
        return label
    }()
    
    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "The number of times the order is repeated"
        label.font = Fonts.cStdBook?.withSize(12.0)
        label.textColor = Colors.lightGrey
        return label
    }()
    
    let quantityPicker = IntegerPicker(min: 1, max: 100)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: .zero)
        
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        addSubview(quantityPicker)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(8.0)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.bottom.equalToSuperview().offset(-8)
            make.leading.equalTo(titleLabel.snp.leading)
        }
        
        quantityPicker.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-32)
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
            make.top.bottom.equalToSuperview()
            
        }
        
    }

}
