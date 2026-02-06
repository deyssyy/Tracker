import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackerViewController = TrackerViewController()
        trackerViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .trackerTab),
            selectedImage: nil)
        
        let statViewController = StatisticViewController()
        statViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .statTab),
            selectedImage: nil)
        
        self.viewControllers = [trackerViewController, statViewController]
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = UIColor.separator
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
