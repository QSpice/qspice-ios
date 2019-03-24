import UIKit
import SnapKit
import QSpiceKit

protocol SpiceCellDelegate: class {
    func spiceCell(cell: SpiceCell, didChange quantity: Int)
    func spiceCell(cell: SpiceCell, didChange metric: Metric)
}

class SpiceCell: UITableViewCell {

    static let reuseId = "SpiceCell"
    
    weak var delegate: SpiceCellDelegate?
    
    var minimumQuantity: Int = 0 {
        didSet {
            if let actionView = actionView as? QuantityPicker {
                actionView.min = minimumQuantity
            }
        }
    }
    
    var quantity: Int = 0 {
        didSet {
            if let actionView = actionView as? QuantityPicker {
                actionView.selectRow(quantity, inComponent: 0, animated: false)
            } else if let actionView = actionView as? UILabel {
                let q = Spice.spiceQuantity(from: quantity).string
                let m = (Metric(rawValue: metric) ?? .teaspoon).name
                actionView.text = "\(q)  \(m)"
            }
        }
    }
    
    var metric: Int = 0 {
        didSet {
            if let actionView = actionView as? QuantityPicker {
                actionView.selectRow(metric, inComponent: 1, animated: false)
            } else if let actionView = actionView as? UILabel {
                let q = Spice.spiceQuantity(from: quantity).string
                let m = (Metric(rawValue: metric) ?? .teaspoon).name
                actionView.text = "\(q)  \(m)"
            }
        }
    }

    enum CellType {
        case unselected
        case display
        case displayActive
        case level
        case ingredientEditable
        case ingredient
    }

    var type: CellType = .unselected {
        didSet {
            setupStyling()
        }
    }
    
    var color: UIColor = Colors.lightGrey {
        didSet {
            colorView.backgroundColor = color
        }
    }
    
    var weight: String = "N/A" {
        didSet {
            spiceWeightLabel.text = "Weight: \(weight)g"
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let colorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black

        return view
    }()

    let spiceNameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.cStdMedium?.withSize(18.0)
        label.textColor = UIColor(red: 153.0 / 255.0, green: 153.0 / 255.0, blue: 153.0 / 255.0, alpha: 1.0)

        return label
    }()

    private let spiceWeightLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.cStdBook?.withSize(14.0)
        label.textColor = UIColor(red: 153.0 / 255.0, green: 153.0 / 255.0, blue: 153.0 / 255.0, alpha: 1.0)
        label.text = "Weight: N/A"

        return label
    }()

    let numberLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.cStdBold?.withSize(24.0)

        return label
    }()

    var actionView: UIView?

    private func setupStyling() {
        if let actionView = actionView {
            actionView.removeFromSuperview()
            self.actionView = nil
        }

        var multiplier: Float = 1.0

        switch type {
        case .unselected:
            colorView.backgroundColor = UIColor(red: 238.0 / 255.0, green: 238.0 / 255.0, blue: 238.0 / 255.0, alpha: 1.0)
            spiceNameLabel.textColor = Colors.lightGrey
            spiceWeightLabel.textColor = Colors.lightGrey
            numberLabel.textColor = Colors.lightGrey
            
            spiceNameLabel.text = "No Spice Selected"
            spiceWeightLabel.text = "Weight: N/A"

            actionView = {
                let imageView = UIImageView()
                imageView.image = UIImage(named: "plus")
                imageView.tintColor = Colors.lightGrey
                return imageView
            }()

            multiplier = 1.80
            contentView.addSubview(actionView!)
            
        case .display, .displayActive:
            spiceNameLabel.textColor = Colors.darkGrey
            spiceWeightLabel.textColor = Colors.lightGrey
            numberLabel.textColor = UIColor.white
            
            if type == .displayActive {
                actionView = {
                    let label = UILabel()
                    label.text = "ACTIVE"
                    label.textColor = Colors.lightGrey
                    label.font = Fonts.cStdBook?.withSize(14.0)
                    
                    return label
                }()
                
                multiplier = 1.8
                contentView.addSubview(actionView!)
            }
            
        case .level:
            spiceNameLabel.textColor = Colors.darkGrey
            spiceWeightLabel.textColor = Colors.lightGrey
            numberLabel.textColor = UIColor.white
            
            actionView = {
                let label = UILabel()
                label.text = ""
                label.textColor = Colors.lightGrey
                label.font = Fonts.cStdBook?.withSize(14.0)
                
                return label
            }()
            
            multiplier = 1.8
            contentView.addSubview(actionView!)
            
        case .ingredient, .ingredientEditable:
            spiceNameLabel.textColor = Colors.darkGrey
            spiceWeightLabel.textColor = Colors.lightGrey
            
            if type == .ingredientEditable {
            
                actionView = {
                    let view = QuantityPicker(min: 0, max: 39)
                    view.selectRow(0, inComponent: 0, animated: true)
                    view.quantityDelegate = self
                    view.min = minimumQuantity
                    return view
                }()
                
                contentView.addSubview(actionView!)
                actionView?.snp.makeConstraints { (make) in
                    make.height.equalTo(58)
                    make.width.equalTo(72)
                }
                
            } else {
                actionView = {
                    let view = UILabel()
                    view.font = Fonts.cStdBook?.withSize(18.0)
                    view.textColor = Colors.lightGrey
                    
                    return view
                }()
                contentView.addSubview(actionView!)
            }
            
            multiplier = 1.75
            
        }

        actionView?.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview().multipliedBy(multiplier)
            make.centerY.equalToSuperview()
        }
    }

    private func setupSubviews() {
        colorView.addSubview(numberLabel)
        contentView.addSubview(colorView)
        contentView.addSubview(spiceNameLabel)
        contentView.addSubview(spiceWeightLabel)

        colorView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(contentView.snp.height)
        }

        spiceNameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.leading.equalTo(colorView.snp.trailing).offset(16)
        }
        
        spiceWeightLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(spiceNameLabel.snp.leading)
            make.top.equalTo(spiceNameLabel.snp.bottom)
            make.bottom.equalToSuperview().offset(-8)
        }

        numberLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        setupStyling()

    }
}

extension SpiceCell: QuantityPickerDelegate {
    func quantityPicker(_ quantityPicker: QuantityPicker, didChange quantity: Int) {
        delegate?.spiceCell(cell: self, didChange: quantity)
    }
    
    func quantityPicker(_ quantityPicker: QuantityPicker, didChange metric: Metric) {
        delegate?.spiceCell(cell: self, didChange: metric)
    }
    
}
