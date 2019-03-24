import UIKit
import QSpiceKit

class QSNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.barTintColor = .white
        navigationBar.shadowImage = UIImage()
        navigationBar.prefersLargeTitles = true
        
        let titleAttributes = [NSAttributedString.Key.foregroundColor: Colors.darkGrey]
        navigationBar.titleTextAttributes = titleAttributes
        navigationBar.largeTitleTextAttributes = titleAttributes
    }

}
