import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackerViewController = TrackerViewController()
        trackerViewController.tabBarItem = UITabBarItem(
            title: "tab_bar_tracker_title".localized,
            image: UIImage(resource: .trackerTab),
            selectedImage: nil)
        
        let statViewController = StatisticViewController()
        statViewController.tabBarItem = UITabBarItem(
            title: "tab_bar_stat_title".localized,
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
