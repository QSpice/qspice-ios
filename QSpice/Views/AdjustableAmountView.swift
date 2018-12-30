import UIKit

class AdjustableAmountView: UIView {
    
    var amount: Int = 1 {
        didSet {
            amountLabel.text = "\(amount)"
        }
    }
    
    var isCaretHidden: Bool = false {
        didSet {
            incrementButton.isHidden = isCaretHidden
            decrementButton.isHidden = isCaretHidden
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    convenience init() {
        self.init(frame: .zero)
        
        prepareSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var caretTint: UIColor = Colors.maroon {
        didSet {
            incrementButton.tintColor = caretTint
            decrementButton.tintColor = caretTint
        }
    }
    
    let incrementButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "up_caret"), for: .normal)
        button.tintColor = Colors.maroon
        return button
    }()
    
    let decrementButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "down_caret"), for: .normal)
        button.tintColor = Colors.maroon
        return button
    }()
    
    let amountLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.cStdBook?.withSize(16.0)
        label.textColor = Colors.lightGrey
        label.text = "1"
        return label
    }()
    
    let metricButton: UIButton = {
        let button = UIButton()
        button.setTitle("tsp", for: .normal)
        button.setTitleColor(Colors.lightGrey, for: .normal)
        button.titleLabel?.font = Fonts.cStdBook?.withSize(16.0)
        button.contentHorizontalAlignment = .left
        
        return button
    }()
    
    private func prepareSubviews() {
        addSubview(incrementButton)
        addSubview(amountLabel)
        addSubview(decrementButton)
        addSubview(metricButton)
        
        incrementButton.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        
        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(incrementButton.snp.bottom).offset(2)
            make.centerX.equalTo(incrementButton.snp.centerX)
        }
        
        decrementButton.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(2)
            make.bottom.leading.equalToSuperview()
        }
        
        metricButton.snp.makeConstraints { make in
            make.leading.equalTo(incrementButton.snp.trailing).offset(8)
            make.trailing.centerY.equalToSuperview()
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.isHidden || !self.isUserInteractionEnabled || self.alpha < 0.01 { return nil }
        
        let incrementInsets = UIEdgeInsets(top: -8, left: -20, bottom: -8, right: -60)
        let incrementButtonFrame = incrementButton.frame.inset(by: incrementInsets)

        let decrementInsets = UIEdgeInsets(top: -8, left: -20, bottom: -8, right: -60)
        let decrementButtonFrame = decrementButton.frame.inset(by: decrementInsets)
        
        let metricButtonFrame = metricButton.frame.insetBy(dx: -3, dy: -1.5)
        
        if metricButtonFrame.contains(point) {
            return metricButton
        }
        
        if incrementButtonFrame.contains(point) {
            return incrementButton
        }
        
        if decrementButtonFrame.contains(point) {
            return decrementButton
        }
        
        return super.hitTest(point, with: event)
    }
}
