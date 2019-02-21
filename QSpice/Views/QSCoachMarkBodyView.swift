import UIKit
import Instructions

class QSCoachMarkBodyView: UIView, CoachMarkBodyView {
    var nextControl: UIControl? {
        return nextButton
    }
    
    weak var highlightArrowDelegate: CoachMarkBodyHighlightArrowDelegate?
    
    var nextButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.maroon
        button.layer.cornerRadius = 8.0
        
        return button
    }()
    
    var hintLabel: UITextView = {
        let label = UITextView()
        
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.darkGray
        label.font = Fonts.cStdBook?.withSize(15.0)
        label.isScrollEnabled = false
        label.isEditable = false
        label.isUserInteractionEnabled = false
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        self.layer.cornerRadius = 4.0
        layer.borderColor = UIColor(hexString: "#E3E3E3").cgColor
        layer.borderWidth = 1.0
        
        self.prepareSubviews()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func prepareSubviews() {
        addSubview(nextButton)
        addSubview(hintLabel)
        
        self.clipsToBounds = true
        
        nextButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(30.0)
            make.width.equalTo(40.0)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        hintLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(nextButton.snp.leading).offset(-10)
        }
    }

}
