import UIKit

struct AppConfig {
    static let maxNumberOfActiveSpices = 6
    static let spiceFile = "spices"
}

struct Fonts {
    static let cStdBook = UIFont(name: "CircularStd-Book", size: 16.0)
    static let cStdMedium = UIFont(name: "CircularStd-Medium", size: 16.0)
    static let cStdBold = UIFont(name: "CircularStd-Bold", size: 16.0)

}

struct Colors {
    static let maroon = UIColor(r: 212.0, g: 56.0, b: 0.0, a: 1.0)
    static let darkGrey = UIColor(r: 77.0, g: 77.0, b: 77.0, a: 1.0)
    static let lightGrey = UIColor(r: 153.0, g: 153.0, b: 153.0, a: 1.0)
    static let success = UIColor(r: 75, g: 181, b: 67, a: 1.0)
    static let warning = UIColor(r: 238, g: 210, b: 2, a: 1.0)
    static let neutral = UIColor(r: 63, g: 68, b: 140, a: 1.0)
}

struct AlertMessages {
    static let initSpices = (title: "Spices Not Loaded", subtitle: "There was an issue loading spices into the application")
    static let eraseActiveSpice = (title: "Spice Not Erased", subtitle: "The active spice could not be erased. Try again.")
    static let selectActiveSpice = (title: "Spice Not Selected", subtitle: "The active spice could not be selected. Try again.")
    static let loadActiveSpices = (title: "Active Spices Not Loaded", subtitle: "The active spices could not be loaded.")
    static let filterSpices = (title: "Spices Not Filtered", subtitle: "The spices could not be filtered.")
    static let loadSpices = (title: "Spices Not Loaded", subtitle: "The spices could not be loaded.")
    static let loadRecipes = (title: "Recipes Not Loaded", subtitle: "The recipes could not be loaded.")
    static let bleConnectFail = (title: "Device Not Connected", subtitle: "The device could not be connected. Try again.")
    static let noOrderBleConnect = (title: "Order Not Created", subtitle: "The automatic spice dispenser is not connected.")
    static let noOrderNoMessage = (title: "Order Not Created", subtitle: "The automatic spice dispenser is unresponsive.")
    static let noOrderInpr = (title: "Order Not Created", subtitle: "An order is currently being made on the device, Would you like to place your order anyway?")
    static let noOrderBusy = (title: "Order Not Created", subtitle: "An order is currently being dispensed on the device, Would you like to cancel it?")
    static let noOrderNoSpices = (title: "Order Not Created", subtitle: "The recipe contains no spices.")
    static let noOrderMissingSpices = (title: "Order Not Created", subtitle: "The recipe contains spices that are not labelled as active.")
    static let spiceLevels = (title: "Spice Levels Low", subtitle: "The spice levels are low for spices in container(s):")
}
