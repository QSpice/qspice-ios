import UIKit
import SnapKit

class SpiceCell: UITableViewCell {

    static let reuseId = "SpiceCell"

    enum CellType {
        case unselected
        case display
        case displayActive
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
        super.init(coder: aDecoder)

        setupSubviews()
    }

    private let colorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black

        return view
    }()

    let spiceNameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.cStdMedium
        label.textColor = UIColor(r: 153.0, g: 153.0, b: 153.0, a: 1.0)

        return label
    }()

    private let spiceWeightLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.cStdBook?.withSize(12.0)
        label.textColor = UIColor(r: 153.0, g: 153.0, b: 153.0, a: 1.0)

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
            colorView.backgroundColor = UIColor(r: 238.0, g: 238.0, b: 238.0, a: 1.0)
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
            
        }

        actionView?.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview().multipliedBy(multiplier)
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualTo(8)
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
