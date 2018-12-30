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
    
    static func load(image imageName: String) -> UIImage? {
        // declare image location
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return nil
        }
        
        let imageUrl = URL(fileURLWithPath: "\(path)/\(imageName).jpg")
        
        if FileManager.default.fileExists(atPath: imageUrl.path),
            let imageData: Data = try? Data(contentsOf: imageUrl),
            let image: UIImage = UIImage(data: imageData, scale: UIScreen.main.scale) {
            return image
        }
        
        return nil
    }
}
