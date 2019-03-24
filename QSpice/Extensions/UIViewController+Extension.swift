import UIKit
import SCLAlertView
import QSpiceKit

extension UIViewController {
    
    enum AlertStyle {
        case neutral
        case success
    }
    
    struct AlertAction {
        var title: String
        var action: () -> Void
        var color: UIColor
    }
    
    func showAlert(title: String, subtitle: String, actions: [AlertAction]? = nil, completion: (() -> Void)? = nil, style: AlertStyle = .neutral, closeTitle: String = "OK") {
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
            for action in actions {
                alert.addButton(action.title, backgroundColor: action.color, textColor: .white, showTimeout: nil, action: action.action)
            }
        } else {
            if let completion = completion {
                alert.addButton("OK", action: completion)
            }
        }
        
        let color: UIColor
        
        switch style {
        case .neutral:
            color = Colors.lightGrey.lighter()
        case .success:
            color = Colors.success
        }
        
        alert.showCustom(title, subTitle: subtitle, color: color, icon: UIImage(), closeButtonTitle: closeTitle, timeout: nil, colorStyle: 0xA429FF, colorTextButton: 0xFFFFFF, circleIconImage: nil, animationStyle: .bottomToTop)
    }
}
