import UIKit
import SnapKit

class SpiceCell: UITableViewCell {

    static let reuseId = "SpiceCell"

    enum CellType {
        case unselected
    }

    var type: CellType = .unselected

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupSubviews()
    }

    let colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black

        return view
    }()

    let spiceNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.cStdMedium
        label.textColor = UIColor(r: 153.0, g: 153.0, b: 153.0, a: 1.0)

        return label
    }()

    let spiceWeightLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.cStdBook?.withSize(12.0)
        label.textColor = UIColor(r: 153.0, g: 153.0, b: 153.0, a: 1.0)

        return label
    }()

    var actionView: UIView?

    private func setupStyling() {
        if let actionView = actionView {
            actionView.removeFromSuperview()
        }

        switch type {
        case .unselected:
            spiceNameLabel.textColor = UIColor(r: 153.0, g: 153.0, b: 153.0, a: 1.0)
            spiceWeightLabel.textColor = UIColor(r: 153.0, g: 153.0, b: 153.0, a: 1.0)
        }
    }

    private func setupSubviews() {
        contentView.addSubview(colorView)
        contentView.addSubview(spiceNameLabel)
        contentView.addSubview(spiceWeightLabel)

        colorView.snp.makeConstraints { (make) -> Void in
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
        }

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
