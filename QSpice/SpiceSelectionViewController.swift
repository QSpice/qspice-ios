import UIKit

class SpiceSelectionViewController: UITableViewController {

    var spiceNumber: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Spice Slot \(spiceNumber)"
        navigationController?.navigationBar.tintColor = UIColor(r: 77.0, g: 77.0, b: 77.0, a: 1.0)
        // Do any additional setup after loading the view.
    }

}
