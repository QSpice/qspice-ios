import UIKit
import Instructions

class ActiveSpicesViewController: UITableViewController {

    private(set) var controller: SpiceController
    let coachController = CoachMarksController()
    
    var spiceLevels = [Int]()
    
    init(controller: SpiceController) {
        self.controller = controller
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        coachController.dataSource = self
        coachController.delegate = self
        
        prepareView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        BLEManager.shared.delegate = self
        BLEManager.shared.write(message: "POLL")
        
        do {
            try controller.fetchActiveSpices()
            tableView.reloadData()
        } catch {
            showAlert(title: AlertMessages.loadActiveSpices.title, subtitle: AlertMessages.loadActiveSpices.subtitle)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        coachController.stop(immediately: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.string(forKey: HintMessages.keys["ActiveSpices"]!) == nil {
            coachController.start(in: .window(over: self))
        }
    }

    // MARK: UITableView Delegate and Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppConfig.maxNumberOfActiveSpices
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SpiceCell.reuseId, for: indexPath) as! SpiceCell

        cell.numberLabel.text = "\(indexPath.row + 1)"
        
        if let activeSpice = controller.activeSpices[indexPath.row + 1] {
            cell.type = .level
            cell.color = UIColor(hexString: activeSpice.color)
            cell.spiceNameLabel.text = activeSpice.name
            let mappedWeight = Spice.mapSpiceWeight(value: activeSpice.weight, metric: controller.weightBasis)
            cell.weight = String(format: "%.1f", mappedWeight)
            
            if let percentLabel = cell.actionView as? UILabel, indexPath.row < spiceLevels.count {
                percentLabel.text = "\(spiceLevels[indexPath.row])%"
            }
            
        } else {
            cell.type = .unselected
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destination = SpiceSelectionViewController(controller: SpiceSelectionController(spiceService: controller.spiceService))
        destination.spiceNumber = indexPath.row + 1
        destination.delegate = self
        
        navigationController?.pushViewController(destination, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let activeSpice = self.controller.activeSpices[indexPath.row + 1] else {
            return nil
        }
        
        // Remove an active spice
        let clearAction = UIContextualAction(style: .normal, title: "Clear") { [weak self] (_, _, completion) in
            if let self = self {
                do {
                    try self.controller.updateActive(spice: activeSpice, slot: -1)
                    try self.controller.fetchActiveSpices()
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    
                    completion(true)
                    return

                } catch {
                    self.showAlert(title: AlertMessages.eraseActiveSpice.title, subtitle: AlertMessages.eraseActiveSpice.subtitle)
                }
            }
            
            completion(false)
            
        }
        
        clearAction.image = UIImage(named: "erase")
        clearAction.backgroundColor = Colors.lightGrey.lighter()
        
        let config = UISwipeActionsConfiguration(actions: [clearAction])
        
        return config
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return controller.activeSpices[indexPath.row + 1] != nil
    }
    
    // MARK: View Management
    
    private func prepareView() {
        title = navigationController?.tabBarItem.title
        
        tableView.register(SpiceCell.self, forCellReuseIdentifier: SpiceCell.reuseId)
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.contentInset = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
    }

}

// MARK: Spice Selection Delegate

extension ActiveSpicesViewController: SpiceSelectionDelegate {
    func didSelect(spice: Spice, for slot: Int) {
        do {
            try controller.updateActive(spice: spice, slot: slot)
        } catch {
            self.showAlert(title: AlertMessages.selectActiveSpice.title, subtitle: AlertMessages.selectActiveSpice.subtitle)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
}

extension ActiveSpicesViewController: BLEManagerDelegate {
    func manager(_ manager: BLEManager, didReceive message: String, error: Error?) {
        if message.contains("OK") {
            spiceLevels = Helpers.parseLevels(string: message)
            tableView.reloadData()
        }
    }
}

extension ActiveSpicesViewController: CoachMarksControllerDataSource {
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        
        let coachBodyView = QSCoachMarkBodyView()
        coachBodyView.hintLabel.text = HintMessages.activeSpicesPage[index]
        
        coachBodyView.nextButton.setTitle("OK", for: .normal)
        
        return (bodyView: coachBodyView, arrowView: coachViews.arrowView)
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 5
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        
        var coachMark: CoachMark = coachMarksController.helper.makeCoachMark()
        
        switch index {
            case 0:
                guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) else {
                    return coachMark
                }
            
                coachMark = coachMarksController.helper.makeCoachMark(for: cell, pointOfInterest: CGPoint(x: cell.frame.maxX - 40, y: cell.frame.maxY))
            
                coachMark.gapBetweenCoachMarkAndCutoutPath = 0.0
                coachMark.horizontalMargin = 16.0
            case 1, 2, 3, 4:
                guard let tabFrame = (self.tabBarController?.tabBar.items?[index].value(forKey: "view") as? UIView)?.frame else {
                    return coachMark
                }
                
                let viewOfInterest = self.tabBarController?.tabBar
                let pointOfInterest = CGPoint(x: tabFrame.midX, y: tabFrame.midY)
                
                return coachMarksController.helper.makeCoachMark(for: viewOfInterest, pointOfInterest: pointOfInterest) { (frame: CGRect) -> UIBezierPath in
                    return UIBezierPath(rect: CGRect(x: tabFrame.minX, y: frame.minY, width: tabFrame.width, height: tabFrame.height))
                }
            
            default:
                break
        }
        
        return coachMark
    }
}

extension ActiveSpicesViewController: CoachMarksControllerDelegate {
    func coachMarksController(_ coachMarksController: CoachMarksController, didEndShowingBySkipping skipped: Bool) {
        UserDefaults.standard.set(true, forKey: HintMessages.keys["ActiveSpices"]!)
    }
}
