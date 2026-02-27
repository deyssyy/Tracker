import UIKit

final class StatisticViewController: UIViewController {
    private let defaultImage = UIImageView()
    private let defaultLabel = UILabel()
    private let headerLabel = UILabel()
    private let mainStack = UIStackView()
    
    private var statistics: [StatisticModel] = []
    private let dataProvider = StatisticsDataProvider(context: CoreDataStack.shared.context)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteNight
        setupHeaderLabel()
        setupDefaultImageAndLabel()
        setupMainStack()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }
    
    private func updateUI() {
        self.statistics = dataProvider.getStatisticsModels()
        
        let isEmpty = statistics.allSatisfy { $0.value == "0" }
        showPlaceholder(isEmpty)
        
        mainStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if !isEmpty {
            for stat in self.statistics {
                let card = StatCardView(value: stat.value, title: stat.title)
                mainStack.addArrangedSubview(card)
            }
        }
    }
    
    private func showPlaceholder(_ isEmpty: Bool) {
        defaultImage.isHidden = !isEmpty
        defaultLabel.isHidden = !isEmpty
        
        mainStack.isHidden = isEmpty
    }
    
    private func setupHeaderLabel(){
        headerLabel.text = "statistic_vc_label_title".localized
        headerLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        headerLabel.textColor = .blackDay
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            headerLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupDefaultImageAndLabel(){
        defaultImage.image = UIImage(resource: .noAnalyze)
        defaultLabel.text = "statistic_vc_default_label".localized
        defaultLabel.font = UIFont.systemFont(ofSize: 12)
        defaultLabel.textColor = .blackDay
        defaultLabel.textAlignment = .center
        defaultImage.translatesAutoresizingMaskIntoConstraints = false
        defaultLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(defaultImage)
        view.addSubview(defaultLabel)
        
        NSLayoutConstraint.activate([
            defaultImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            defaultImage.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -357),
            defaultImage.widthAnchor.constraint(equalToConstant: 80),
            defaultImage.heightAnchor.constraint(equalToConstant: 80),
            defaultLabel.topAnchor.constraint(equalTo: defaultImage.bottomAnchor, constant: 8),
            defaultLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            defaultLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupMainStack(){
        mainStack.axis = .vertical
        mainStack.spacing = 16
        view.addSubview(mainStack)
        
        
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 77),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
