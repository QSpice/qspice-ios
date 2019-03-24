import CoreGraphics

public extension CGFloat {
    public static var π: CGFloat {
        return CGFloat.pi
    }
}

public extension CGPoint {
    public var vector: CGVector {
        return CGVector(dx: x, dy: y)
    }
}

public extension CGVector {
    public var magnitude: CGFloat {
        return sqrt(dx*dx + dy*dy)
    }
    
    public var point: CGPoint {
        return CGPoint(x: dx, y: dy)
    }
    
    public func apply(transform t: CGAffineTransform) -> CGVector {
        return point.applying(t).vector
    }
}

public func clip<T: Comparable>(_ lower: T, _ upper: T, _ value: T) -> T {
    return max(lower, min(upper, value))
}
