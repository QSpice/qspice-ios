import UIKit

public struct AppConfig {
    public static let maxNumberOfActiveSpices = 6
    public static let spiceFile = "spices"
}

public struct Fonts {
    public static let cStdBook = UIFont(name: "CircularStd-Book", size: 16.0)
    public static let cStdMedium = UIFont(name: "CircularStd-Medium", size: 16.0)
    public static let cStdBold = UIFont(name: "CircularStd-Bold", size: 16.0)

}

public struct Colors {
    public static let maroon = UIColor(r: 212.0, g: 56.0, b: 0.0, a: 1.0)
    public static let darkGrey = UIColor(r: 77.0, g: 77.0, b: 77.0, a: 1.0)
    public static let lightGrey = UIColor(r: 153.0, g: 153.0, b: 153.0, a: 1.0)
    public static let success = UIColor(r: 75, g: 181, b: 67, a: 1.0)
    public static let warning = UIColor(r: 238, g: 210, b: 2, a: 1.0)
    public static let neutral = UIColor(r: 63, g: 68, b: 140, a: 1.0)
}

public struct AlertMessages {
    public static let initSpices = (title: "Spices Not Loaded", subtitle: "There was an issue loading spices into the application")
    public static let eraseActiveSpice = (title: "Spice Not Erased", subtitle: "The active spice could not be erased. Try again.")
    public static let selectActiveSpice = (title: "Spice Not Selected", subtitle: "The active spice could not be selected. Try again.")
    public static let loadActiveSpices = (title: "Active Spices Not Loaded", subtitle: "The active spices could not be loaded.")
    public static let filterSpices = (title: "Spices Not Filtered", subtitle: "The spices could not be filtered.")
    public static let loadSpices = (title: "Spices Not Loaded", subtitle: "The spices could not be loaded.")
    public static let loadRecipes = (title: "Recipes Not Loaded", subtitle: "The recipes could not be loaded.")
    public static let bleConnectFail = (title: "Device Not Connected", subtitle: "The device could not be connected. Try again.")
    public static let noOrderBleConnect = (title: "Order Not Created", subtitle: "The automatic spice dispenser is not connected.")
    public static let noOrderNoMessage = (title: "Order Not Created", subtitle: "The automatic spice dispenser is unresponsive.")
    public static let noOrderInpr = (title: "Order Not Created", subtitle: "An order is currently being made on the device, Would you like to place your order anyway?")
    public static let noOrderBusy = (title: "Order Not Created", subtitle: "An order is currently being dispensed on the device, Would you like to cancel it?")
    public static let noOrderNoSpices = (title: "Order Not Created", subtitle: "The recipe contains no spices.")
    public static let noOrderMissingSpices = (title: "Order Not Created", subtitle: "The recipe contains spices that are not labelled as active.")
    public static let noOrderExceededAmount = (title: "Order Not Created", subtitle: "Order exceeded maximum amount that can fit inside the bowl (30 tsp). Please create a smaller order")
    public static let spiceLevels = (title: "Spice Levels Low", subtitle: "The spice levels are low for spices in container(s):")
    public static let resetHints = (title: "Reset All Hints", subtitle: "Resetting all hints is irreversible, are you sure you want to proceed?")
    public static let invalidName = (title: "Recipe Name Invalid", subtitle: "The recipe name should not be left empty.")
    public static let couldNotCancel = (title: "Order Not Cancelled", subtitle: "The order could not be cancelled. Try again.")
}

public struct HintMessages {
    public static let keys = [
        "ActiveSpices": "ActiveSpicesViewControllerCoach",
        "Recipes": "RecipesViewControllerCoach",
        "CreateOrder": "CreateOrderViewControllerCoach"
    ]
    
    public static let activeSpicesPage = [
        "Welcome to QSpice! Start by labelling the spices you placed inside the QSpice automatic spice dispenser.",
        "You will find all your delicious saved recipes in this tab!",
        "Once you've labelled spices or created a recipe, you'll be able to create you first order here.",
        "Visit this tab after you've dispensed an order to see a detail history of all your orders.",
        "Connect to your new QSpice automatic spice dispenser in this tab."
    ]
    
    public static let recipesPage = [
        "Tap here to add a new recipe, so you can dispense a combination of spices more easily in the future."
    ]
    
    public static let createOrderPage = [
        "Use this button to start creating an order for an ad-hoc list of spices.",
        "Use this button to start creating an order from one of your custom recipes."
    ]
}
