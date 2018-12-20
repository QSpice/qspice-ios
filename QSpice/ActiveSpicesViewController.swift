import UIKit

class ActiveSpicesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()

        tableView.register(SpiceCell.self, forCellReuseIdentifier: SpiceCell.reuseId)
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

        return cell
    }

}
