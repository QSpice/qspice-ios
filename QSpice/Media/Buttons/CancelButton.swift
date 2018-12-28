import UIKit

class CancelButton: UIButton {

    var lineWidth: CGFloat = 1.0
    var color: UIColor = .white

    // draw an × using UIBezierPath
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        drawX(in: rect)
    }

    /**
        Draw an × using UIBezierPath
    */
    private func drawX(in rect: CGRect) {
        let path = UIBezierPath()
        path.lineWidth = lineWidth

        let vertical = UIBezierPath(roundedRect: CGRect(x: (rect.width - lineWidth) / 2, y: 0,
                                                        width: lineWidth, height: rect.height),
                                                        cornerRadius: rect.width / 2)

        let horizontal = UIBezierPath(roundedRect: CGRect(x: 0, y: (rect.height - lineWidth) / 2,
                                                          width: rect.width, height: lineWidth),
                                                          cornerRadius: rect.width / 2)
        path.append(vertical)
        path.append(horizontal)

        // rotate 45 degrees
        path.apply(CGAffineTransform(translationX: -bounds.width / 2, y: -bounds.height / 2))
        path.apply(CGAffineTransform(rotationAngle: CGFloat.π / 4))
        path.apply(CGAffineTransform(translationX: bounds.width / 2, y: bounds.height / 2))

        color.setFill()
        path.fill()
    }

}
