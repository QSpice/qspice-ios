import UIKit
import QSpiceKit

class CameraButton: UIButton {

    var color: UIColor = .white
    let innerCircle = CAShapeLayer()
    let borderCircle = CAShapeLayer()

    override var isEnabled: Bool {
        didSet {
            layer.opacity = isEnabled ? 1.0 : 0.5
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        drawButton()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(ovalIn: rect)

        color.setFill()
        path.fill()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        positionButton()
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) { [unowned self] in
                if self.isHighlighted {
                    self.innerCircle.transform = CATransform3DMakeScale(0.9, 0.9, 1.0)
                } else {
                    self.innerCircle.transform = CATransform3DIdentity
                }
            }
        }
    }

    private func drawButton() {
        layer.insertSublayer(borderCircle, at: 0)
        layer.insertSublayer(innerCircle, at: 1)

    }

    private func positionButton() {
        let width = bounds.width * 0.8
        let height = bounds.height * 0.8

        borderCircle.fillColor = Colors.darkGrey.cgColor
        borderCircle.position = CGPoint(x: layer.bounds.midX, y: layer.bounds.midY)
        let borderCirclePath = UIBezierPath(ovalIn: CGRect(x: -(width + 2) / 2, y: -(height + 2) / 2,
                                                           width: width + 2, height: height + 2))
        borderCircle.path = borderCirclePath.cgPath

        innerCircle.fillColor = color.cgColor
        innerCircle.position = CGPoint(x: layer.bounds.midX, y: layer.bounds.midY)
        let innerCirclepath = UIBezierPath(ovalIn: CGRect(x: -width / 2, y: -height / 2, width: width, height: height))
        innerCircle.path = innerCirclepath.cgPath
    }

}
