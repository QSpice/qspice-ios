import UIKit

class QSTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.tintColor = Colors.maroon
        tabBar.unselectedItemTintColor = Colors.darkGrey
    }
    
}
