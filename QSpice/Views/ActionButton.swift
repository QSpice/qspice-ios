import UIKit
import QSpiceKit

class ActionButton: UIButton {
    
    var labelText: String?
    
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                labelText = titleLabel?.text
                setTitle("", for: .normal)
                activityIndicator.startAnimating()
            } else {
                setTitle(labelText, for: .normal)
                activityIndicator.stopAnimating()
            }
        }
    }
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setTitleColor(Colors.maroon, for: .normal)
        
        setTitleColor(Colors.maroon.lighter(), for: .highlighted)
        setTitleColor(Colors.lightGrey, for: .disabled)
        
        titleLabel?.font = Fonts.cStdBook
        
        layer.borderColor = Colors.maroon.cgColor
        layer.cornerRadius = 4.0
        layer.borderWidth = 1.0
        
        self.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    convenience init() {
        self.init(frame: .zero)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                layer.borderColor = Colors.maroon.cgColor
            } else {
                layer.borderColor = Colors.lightGrey.cgColor
            }
        }
    }
    
}
