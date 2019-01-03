import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let window: UIWindow = UIWindow(frame: UIScreen.main.bounds)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let spiceService = SpiceService(context: persistentContainer.viewContext)
        let recipeService = RecipeService(context: persistentContainer.viewContext)
        
        let spiceController = SpiceController(spiceService: spiceService)
        let recipeController = RecipeController(recipeService: recipeService)
        let orderController = OrderController(spiceService: spiceService)
        let settingsController = SettingsController()
        
        let tabBarController = QSTabBarController()
        
        let activeSpicesViewController = ActiveSpicesViewController(controller: spiceController)
        let recipesViewController = RecipesViewController(controller: recipeController)
        let createOrderViewController = CreateOrderViewController(controller: orderController)
        let orderHistoryViewController = OrderHistoryViewController(controller: orderController)
        let settingsViewController = SettingsViewController(controller: settingsController)

        let tabBarItemInfo = [
            (name: "Spices", image: UIImage(named: "spice")),
            (name: "Recipes", image: UIImage(named: "chef")),
            (name: "Orders", image: UIImage(named: "order")),
            (name: "History", image: UIImage(named: "timeline")),
            (name: "Settings", image: UIImage(named: "settings"))
        ]
        
        let viewControllers = [
            QSNavigationController(rootViewController: activeSpicesViewController),
            UINavigationController(rootViewController: recipesViewController),
            createOrderViewController,
            UINavigationController(rootViewController: orderHistoryViewController),
            UINavigationController(rootViewController: settingsViewController)
        ]
        
        for (i, viewController) in viewControllers.enumerated() {
            let (name, image) = tabBarItemInfo[i]
            viewController.tabBarItem = UITabBarItem(title: name, image: image, selectedImage: image)
        }
        
        tabBarController.viewControllers = viewControllers
        
        window.rootViewController = tabBarController

        window.makeKeyAndVisible()
        
        do {
            try spiceController.initializeSpicesIfNeeded()
        } catch {
            activeSpicesViewController.showAlert(title: AlertMessages.initSpices.title, subtitle: AlertMessages.initSpices.subtitle)
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "QSpice")
        container.loadPersistentStores(completionHandler: { [weak self] (_, error) in
            if let error = error {
                self?.window.rootViewController?.showAlert(title: "Data Not Loaded", subtitle: error.localizedDescription)
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                window.rootViewController?.showAlert(title: "Data Not Saved", subtitle: error.localizedDescription)
            }
        }
    }

}
