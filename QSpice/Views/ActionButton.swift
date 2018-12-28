import UIKit

class ActionButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setTitleColor(Colors.maroon, for: .normal)
        
        setTitleColor(Colors.maroon.lighter(), for: .highlighted)
        
        titleLabel?.font = Fonts.cStdBook
        
        layer.borderColor = Colors.maroon.cgColor
        layer.cornerRadius = 4.0
        layer.borderWidth = 1.0
    }
    
    convenience init() {
        self.init(frame: .zero)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
