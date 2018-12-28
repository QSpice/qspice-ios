import UIKit

extension UIImage {
    func crop(rect: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, scale)
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.translateBy(x: -rect.origin.x, y: -rect.origin.y)
        draw(at: .zero)
        
        let cropped = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return cropped
    }
}
