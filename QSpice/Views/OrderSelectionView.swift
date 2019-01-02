import UIKit

class OrderSelectionView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    var labelText: String {
        set {
            buttonLabel.text = newValue
        }
        
        get {
            return buttonLabel.text ?? ""
        }
    }
    
    var color: UIColor? {
        set {
            actionButton.backgroundColor = newValue
        }
        
        get {
            return actionButton.backgroundColor
        }
    }
    
    var image: UIImage? {
        set {
            actionButton.setImage(newValue, for: .normal)
        }
        
        get {
            return actionButton.image(for: .normal)
        }
    }
    
    private let actionButton: UIButton = {
        let button = UIButton()
        button.imageEdgeInsets = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.tintColor = .white
        return button
    }()
    
    func addTarget(target: Any?, action: Selector, for event: UIControl.Event) {
        actionButton.addTarget(target, action: action, for: event)
    }
    
    private let buttonLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.cStdBook
        
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        actionButton.layer.cornerRadius = actionButton.bounds.width / 2
    }
    
    convenience init() {
        self.init(frame: .zero)
        
        addSubview(actionButton)
        addSubview(buttonLabel)
        
        actionButton.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(buttonLabel.snp.top).offset(-8)
            make.height.equalTo(actionButton.snp.width)
        }
        
        buttonLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
