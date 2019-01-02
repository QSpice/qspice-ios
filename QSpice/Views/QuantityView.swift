import UIKit

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
    
    let amountView: AdjustableAmountView = {
        let view = AdjustableAmountView()
        view.caretTint = Colors.darkGrey
        view.metricButton.setTitle("", for: .normal)
        return view
    }()
    
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
        addSubview(amountView)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(8.0)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.bottom.equalToSuperview().offset(-8)
            make.leading.equalTo(titleLabel.snp.leading)
        }
        
        amountView.snp.makeConstraints { make in
            make.centerY.trailing.equalToSuperview()
            
        }
        
    }

}
