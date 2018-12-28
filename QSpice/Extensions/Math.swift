import CoreGraphics

extension CGFloat {
    static var π: CGFloat {
        return CGFloat.pi
    }
}

extension CGPoint {
    var vector: CGVector {
        return CGVector(dx: x, dy: y)
    }
}

extension CGVector {
    var magnitude: CGFloat {
        return sqrt(dx*dx + dy*dy)
    }
    
    var point: CGPoint {
        return CGPoint(x: dx, y: dy)
    }
    
    func apply(transform t: CGAffineTransform) -> CGVector {
        return point.applying(t).vector
    }
}

func clip<T: Comparable>(_ lower: T, _ upper: T, _ value: T) -> T {
    return max(lower, min(upper, value))
}
