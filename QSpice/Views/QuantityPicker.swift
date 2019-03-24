import UIKit

protocol QuantityPickerDelegate: class {
    func quantityPicker(_ quantityPicker: QuantityPicker, didChange quantity: Int)
    func quantityPicker(_ quantityPicker: QuantityPicker, didChange metric: Metric)
}

class QuantityPicker: UIPickerView {

    weak var quantityDelegate: QuantityPickerDelegate?
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

extension QuantityPicker: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return (max - min) + 2
        }
        
        if component == 1 {
            return Metric.allCases.count
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.font = Fonts.cStdBook?.withSize(18.0)
        label.textColor = Colors.lightGrey
        
        if component == 0 {
            label.text = Spice.spiceQuantity(from: min + row).string
            label.textAlignment = .center
        }
        
        if component == 1 {
            label.text = (Metric(rawValue: row) ?? .teaspoon).name
            label.textAlignment = .left
        }
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            quantityDelegate?.quantityPicker(self, didChange: min + row)
        }
        
        if component == 1 {
            quantityDelegate?.quantityPicker(self, didChange: Metric(rawValue: row) ?? .teaspoon)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if component == 0 {
            return 31
        }
        
        return 40
    }
    
    override func selectRow(_ row: Int, inComponent component: Int, animated: Bool) {
        if component == 0 {
            super.selectRow(row - min, inComponent: component, animated: animated)
        } else {
            super.selectRow(row, inComponent: component, animated: animated)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
}
