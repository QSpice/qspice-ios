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
}

struct AlertMessages {
    static let initSpices = (title: "Spices Not Loaded", subtitle: "There was an issue loading spices into the application")
    static let eraseActiveSpice = (title: "Spice Not Erased", subtitle: "The active spice could not be erased. Try again.")
    static let selectActiveSpice = (title: "Spice Not Selected", subtitle: "The active spice could not be selected. Try again.")
    static let loadActiveSpices = (title: "Active Spices Not Loaded", subtitle: "The active spices could not be loaded.")
}
