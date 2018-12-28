import UIKit

class CroppingView: UIView {

    private let gridView: GridView = {
        let grid = GridView()
        grid.translatesAutoresizingMaskIntoConstraints = false

        return grid
    }()

    var gridRect: CGRect {
        return gridView.frame
    }

    var gridPadding: CGFloat {
        return gridView.pad
    }

    private enum Mask: Int {
        case top = 0
        case left = 1
        case bottom = 2
        case right = 3
    }

    private let masks: [UIView] = {
        var masks = [UIView]()

        for _ in 0...3 {
            let mask = UIView()
            mask.translatesAutoresizingMaskIntoConstraints = false
            mask.backgroundColor = .black
            mask.layer.opacity = 0.60

            masks.append(mask)
        }

        return masks
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // grid is a square
        let gridWidth = bounds.width - (2 * gridPadding)
        let gridHeight = gridWidth

        gridView.frame = CGRect(x: 0, y: 0, width: gridWidth, height: gridHeight)
        gridView.center = CGPoint(x: bounds.midX, y: bounds.midY)

    }

    private func setupSubviews() {
        masks.forEach { addSubview($0) }
        addSubview(gridView)

        NSLayoutConstraint.activate([
            gridView.centerYAnchor.constraint(equalTo: centerYAnchor),
            gridView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            gridView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            gridView.heightAnchor.constraint(equalTo: gridView.widthAnchor),

            masks[Mask.top.rawValue].topAnchor.constraint(equalTo: topAnchor),
            masks[Mask.top.rawValue].leftAnchor.constraint(equalTo: gridView.leftAnchor),
            masks[Mask.top.rawValue].rightAnchor.constraint(equalTo: gridView.rightAnchor),
            masks[Mask.top.rawValue].bottomAnchor.constraint(equalTo: gridView.topAnchor),

            masks[Mask.left.rawValue].topAnchor.constraint(equalTo: topAnchor),
            masks[Mask.left.rawValue].leftAnchor.constraint(equalTo: leftAnchor),
            masks[Mask.left.rawValue].rightAnchor.constraint(equalTo: gridView.leftAnchor),
            masks[Mask.left.rawValue].bottomAnchor.constraint(equalTo: bottomAnchor),

            masks[Mask.bottom.rawValue].topAnchor.constraint(equalTo: gridView.bottomAnchor),
            masks[Mask.bottom.rawValue].leftAnchor.constraint(equalTo: gridView.leftAnchor),
            masks[Mask.bottom.rawValue].rightAnchor.constraint(equalTo: gridView.rightAnchor),
            masks[Mask.bottom.rawValue].bottomAnchor.constraint(equalTo: bottomAnchor),

            masks[Mask.right.rawValue].topAnchor.constraint(equalTo: topAnchor),
            masks[Mask.right.rawValue].leftAnchor.constraint(equalTo: gridView.rightAnchor),
            masks[Mask.right.rawValue].rightAnchor.constraint(equalTo: rightAnchor),
            masks[Mask.right.rawValue].bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
