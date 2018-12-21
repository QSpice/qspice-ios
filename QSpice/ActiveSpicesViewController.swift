import UIKit

class ActiveSpicesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()

        tableView.register(SpiceCell.self, forCellReuseIdentifier: SpiceCell.reuseId)
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSpiceSelectionSegue" {
            if let indexPath = sender as? IndexPath {
                let destinationVC = segue.destination as? SpiceSelectionViewController
                destinationVC?.spiceNumber = indexPath.row + 1
            }
        }
    }

}

extension ActiveSpicesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppConfig.maxNumberOfActiveSpices
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SpiceCell.reuseId, for: indexPath) as! SpiceCell

        cell.spiceNameLabel.text = "No Spice Selected"
        cell.spiceWeightLabel.text = "Weight: N/A"
        cell.numberLabel.text = "\(indexPath.row + 1)"

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toSpiceSelectionSegue", sender: indexPath)
    }

}
