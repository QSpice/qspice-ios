import UIKit

class GridView: UIView {

    private var outerLines = [GridLine]()
    private var horizontalLines = [GridLine]()
    private var verticalLines = [GridLine]()
    private var corners = [GridLine]()

    var lineWidth: CGFloat = 1.0
    var cornerSize = CGSize(width: 2.0, height: 16.0)
    var pad: CGFloat = 16.0

    override init(frame: CGRect) {
        super.init(frame: frame)

        createLines()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layoutOuterLines()
        layoutInnerLines()
        layoutCorners()

    }

    private func layoutOuterLines() {
        let lineLength = bounds.size.width + lineWidth

        for line in outerLines {
            var lineFrame: CGRect

            switch line.lineLocation {
            case .top:
                lineFrame = CGRect(x: bounds.minX, y: bounds.minY, width: lineLength, height: lineWidth)
            case .right:
                lineFrame = CGRect(x: bounds.maxX, y: bounds.minY, width: lineWidth, height: lineLength)
            case .bottom:
                lineFrame = CGRect(x: bounds.minX, y: bounds.maxY, width: lineLength, height: lineWidth)
            case .left:
                lineFrame = CGRect(x: bounds.minX, y: bounds.minY, width: lineWidth, height: lineLength)
            default:
                lineFrame = CGRect.zero
                line.removeFromSuperview()
            }

            line.frame = lineFrame
        }
    }

    private func layoutInnerLines() {
        let lineLength = bounds.size.width + lineWidth

        for (index, line) in horizontalLines.enumerated() {
            let lineDistance = lineLength / CGFloat(horizontalLines.count + 1)
            let offset: CGFloat = CGFloat(index) + 1.0

            line.frame = CGRect(x: bounds.minX, y: offset * lineDistance, width: lineLength, height: lineWidth)
        }

        for (index, line) in verticalLines.enumerated() {
            let lineDistance = lineLength / CGFloat(verticalLines.count + 1)
            let offset: CGFloat = CGFloat(index) + 1.0

            line.frame = CGRect(x: offset * lineDistance, y: bounds.minY, width: lineWidth, height: lineLength)
        }
    }

    private func layoutCorners() {
        let width = cornerSize.width
        let height = cornerSize.height

        for line in corners {
            var lineFrame = CGRect.zero

            switch (line.lineLocation, line.lineType) {
            case (.topLeft, .horizontalCorner):
                lineFrame = CGRect(x: bounds.minX - width, y: bounds.minY - width, width: height, height: width)
            case (.topLeft, .verticalCorner):
                lineFrame = CGRect(x: bounds.minX - width, y: bounds.minY - width, width: width, height: height)
            case (.topRight, .horizontalCorner):
                lineFrame = CGRect(x: bounds.maxX + width - height, y: bounds.minY - width, width: height, height: width)
            case (.topRight, .verticalCorner):
                lineFrame = CGRect(x: bounds.maxX + lineWidth, y: bounds.minY - width, width: width, height: height)
            case (.bottomLeft, .horizontalCorner):
                lineFrame = CGRect(x: bounds.minX - width, y: bounds.maxY + lineWidth, width: height, height: width)
            case (.bottomLeft, .verticalCorner):
                lineFrame = CGRect(x: bounds.minX - width, y: bounds.maxY + width - height, width: width, height: height)
            case (.bottomRight, .horizontalCorner):
                lineFrame = CGRect(x: bounds.maxX + width - height + lineWidth, y: bounds.maxY + lineWidth, width: height, height: width)
            case (.bottomRight, .verticalCorner):
                lineFrame = CGRect(x: bounds.maxX + lineWidth, y: bounds.maxY + width - height, width: width, height: height)
            default:
                line.removeFromSuperview()
            }

            line.frame = lineFrame
        }
    }

    private func createLines() {
        outerLines = [
            createLine(.line, at: .top),
            createLine(.line, at: .right),
            createLine(.line, at: .bottom),
            createLine(.line, at: .left)
        ]

        horizontalLines = [
            createLine(.line, at: .inside),
            createLine(.line, at: .inside)
        ]

        verticalLines = [
            createLine(.line, at: .inside),
            createLine(.line, at: .inside)
        ]

        corners = [
            createLine(.horizontalCorner, at: .topLeft),
            createLine(.verticalCorner, at: .topLeft),
            createLine(.horizontalCorner, at: .topRight),
            createLine(.verticalCorner, at: .topRight),
            createLine(.horizontalCorner, at: .bottomLeft),
            createLine(.verticalCorner, at: .bottomLeft),
            createLine(.horizontalCorner, at: .bottomRight),
            createLine(.verticalCorner, at: .bottomRight)
        ]
    }

    private func createLine(_ type: GridLine.LineType, at location: GridLine.LineLocation) -> GridLine {
        let line = GridLine(as: type, at: location)
        line.backgroundColor = .white
        addSubview(line)

        return line
    }

}

class GridLine: UIView {
    public enum LineType {
        case horizontalCorner
        case verticalCorner
        case line

    }

    public enum LineLocation {
        case top, bottom, right, left
        case inside
        case topLeft, topRight, bottomLeft, bottomRight
    }

    private(set) var lineType: LineType
    private(set) var lineLocation: LineLocation

    init(as type: LineType, at location: LineLocation) {

        self.lineType = type
        self.lineLocation = location

        super.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
