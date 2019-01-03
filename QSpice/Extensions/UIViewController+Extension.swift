import UIKit
import SCLAlertView

extension UIViewController {
    func showAlert(title: String, subtitle: String, actions: [Any]? = nil, completion: (() -> Void)? = nil) {
        let appearance = SCLAlertView.SCLAppearance(
            kTitleTop: 16.0,
            kWindowWidth: ((UIScreen.main.nativeBounds.width) / (UIScreen.main.nativeScale)) * 0.75,
            kTitleFont: Fonts.cStdMedium?.withSize(20.0) ?? UIFont.systemFont(ofSize: 20.0),
            kTextFont: Fonts.cStdBook?.withSize(16.0) ?? UIFont.systemFont(ofSize: 16.0),
            showCloseButton: completion == nil,
            showCircularIcon: false,
            contentViewCornerRadius: 4.0
        )
        
        let alert = SCLAlertView(appearance: appearance)
        
        if let actions = actions {
            
        } else {
            if let completion = completion {
                alert.addButton("OK", action: completion)
            }
        }
        
        alert.showCustom(title, subTitle: subtitle, color: Colors.lightGrey, icon: UIImage(), closeButtonTitle: "OK", timeout: nil, colorStyle: 0xA429FF, colorTextButton: 0xFFFFFF, circleIconImage: nil, animationStyle: .bottomToTop)
    }
}
