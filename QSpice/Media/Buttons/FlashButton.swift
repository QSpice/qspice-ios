import UIKit

class FlashButton: UIButton {

    var isOn: Bool = false {
        didSet {
            isOn ? setImage(#imageLiteral(resourceName: "flash-enabled.pdf"), for: .normal) : setImage(#imageLiteral(resourceName: "flash-disabled.pdf"), for: .normal)
        }
    }

}
