import UIKit

final class OnboardingViewController:UIPageViewController {
    private let pages = [
        OnboardingContentViewController(labelText: "Отслеживайте только то, что хотите", imageName: "onborad1"),
        OnboardingContentViewController(labelText: "Даже если это не литры воды и йога", imageName: "onborad2")
    ]
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blackDay
        button.layer.cornerRadius = 16
        return button
    }()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .blackDay
        pageControl.pageIndicatorTintColor = .lightGray
        return pageControl
    }()
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        dataSource = self
        delegate = self
        
        if let initPage = pages.first {
            setViewControllers([initPage], direction: .forward, animated: true, completion: nil)
        }
        
        setupFixedElements()
    }
    
    private func setupFixedElements(){
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = pages.count
        
        view.addSubview(actionButton)
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            actionButton.heightAnchor.constraint(equalToConstant: 60),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -24)
        ])
    }
    
    @objc private func actionButtonTapped(){
        UserDefaults.standard.set(true, forKey: "notFirstAppLaunch")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let tabBarController = TabBarController()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        return
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? OnboardingContentViewController,
              let index = pages.firstIndex(of: currentVC),
              index > 0 else {
            return nil
        }
        return pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? OnboardingContentViewController,
              let index = pages.firstIndex(of: currentVC),
              index < pages.count - 1 else {
            return nil
        }
        return pages[index + 1]
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if completed,
           let currentVC = pageViewController.viewControllers?.first as? OnboardingContentViewController,
           let index = pages.firstIndex(of: currentVC) {
            
            pageControl.currentPage = index
        }
    }
}
