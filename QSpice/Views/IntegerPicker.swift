import UIKit
import QSpiceKit

class IntegerPicker: UIPickerView {

    var min: Int = 0
    var max: Int = 10
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        dataSource = self
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(min: Int, max: Int) {
        self.init(frame: .zero)
        
        self.max = max
        self.min = min
    }
    
}

extension IntegerPicker: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return max - min
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.font = Fonts.cStdBook?.withSize(24.0)
        label.textColor = Colors.lightGrey
        label.textAlignment = .center
        label.text = "\(min + row)"
        return label
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
}
