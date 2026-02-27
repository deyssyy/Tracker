import UIKit

final class CategoryViewController: UIViewController{
    private let createNewCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("category_vc_add_button_title".localized, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.whiteNight, for: .normal)
        button.backgroundColor = .blackDay
        button.layer.cornerRadius = 16
        return button
    }()
    
    private let categoriesTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    private let defaultImage = UIImageView()
    private let defaultLabel = UILabel()
    
    private let viewModel: TrackerViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "category_vc_header_title".localized
        setupNavigationController()
        setupCreateNewCategoryButton()
        setupDefaultImageAndLabel()
        setupCategoriesTableView()
        checkIsTableEmpty()
        bind()
    }
    
    init(viewModel: TrackerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNavigationController(){
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.blackDay,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        
        appearance.largeTitleTextAttributes = textAttributes
        appearance.titleTextAttributes = textAttributes
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        navigationController?.navigationBar.isTranslucent = true
    }
    
    private func bind() {
        viewModel.onCategoriesUpdated = { [weak self] update in
            guard let self = self else { return }
            
            self.checkIsTableEmpty()
            
            if !self.categoriesTableView.isHidden {
                self.categoriesTableView.performBatchUpdates {
                    self.categoriesTableView.insertRows(at: update.insertedIndexPaths, with: .automatic)
                    self.categoriesTableView.deleteRows(at: update.deletedIndexPaths, with: .automatic)
                    self.categoriesTableView.reloadRows(at: update.updatedIndexPaths, with: .automatic)
                }
            } else {
                self.categoriesTableView.reloadData()
            }
        }
    }
    
    private func checkIsTableEmpty(){
        defaultLabel.isHidden = viewModel.categoriesCount == 0 ? false : true
        defaultImage.isHidden = viewModel.categoriesCount == 0 ? false : true
        categoriesTableView.isHidden = viewModel.categoriesCount == 0 ? true : false
    }
    
    private func setupDefaultImageAndLabel(){
        defaultImage.image = UIImage(resource: .noTask)
        defaultLabel.text = "category_vc_default_label_title".localized
        defaultLabel.font = UIFont.systemFont(ofSize: 12)
        defaultLabel.textColor = .blackDay
        defaultLabel.numberOfLines = 2
        defaultLabel.textAlignment = .center
        defaultImage.translatesAutoresizingMaskIntoConstraints = false
        defaultLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(defaultImage)
        view.addSubview(defaultLabel)
        
        NSLayoutConstraint.activate([
            defaultImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            defaultImage.bottomAnchor.constraint(equalTo: createNewCategoryButton.topAnchor, constant: -232),
            defaultImage.widthAnchor.constraint(equalToConstant: 80),
            defaultImage.heightAnchor.constraint(equalToConstant: 80),
            defaultLabel.topAnchor.constraint(equalTo: defaultImage.bottomAnchor, constant: 8),
            defaultLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            defaultLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupCreateNewCategoryButton(){
        createNewCategoryButton.addTarget(self, action: #selector(createNewCategoryButtonTaped), for: .touchUpInside)
        createNewCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createNewCategoryButton)
        
        NSLayoutConstraint.activate([
            createNewCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createNewCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createNewCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createNewCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupCategoriesTableView(){
        categoriesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "categoryCell")
        view.addSubview(categoriesTableView)
        
        NSLayoutConstraint.activate([
            categoriesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoriesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoriesTableView.bottomAnchor.constraint(equalTo: createNewCategoryButton.topAnchor, constant: -114)
        ])
        
        categoriesTableView.delegate = self
        categoriesTableView.dataSource = self
    }
    
    @objc func createNewCategoryButtonTaped(){
        let newCategoryVC = NewCategoryViewController(viewModel: viewModel)
        let navigationVC = UINavigationController(rootViewController: newCategoryVC)
        navigationVC.modalPresentationStyle = .popover
        present(navigationVC, animated: true)
    }
}

extension CategoryViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath)
        categoriesTableView.reloadData()
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil){ [weak self] _ in
            let editAction = UIAction(title: "category_vc_action_edit_title".localized){ _ in
                guard let self = self,
                      let cell = tableView.cellForRow(at: indexPath),
                      let text = cell.textLabel?.text else { return }
                let editVC = EditCategoryViewController(viewModel: self.viewModel, oldName: text)
                let navigationVC = UINavigationController(rootViewController: editVC)
                navigationVC.modalPresentationStyle = .popover
                self.present(navigationVC, animated: true)
            }
            let deleteAction = UIAction(title: "category_vc_action_delete_title".localized, attributes: .destructive){[weak self] _ in
                guard let self = self else { return }
                let alert = UIAlertController(title: "category_vc_delete_alert_title".localized, message: "", preferredStyle: .actionSheet)
                let deleteAction = UIAlertAction(title:  "category_vc_delete_alert_delete_button_title".localized,style: .destructive){ _ in
                    self.viewModel.deleteCategory(at: indexPath)
                }
                let cancelAction = UIAlertAction(title: "category_vc_delete_alert_cancel_button_title".localized, style: .cancel){_ in
                    alert.dismiss(animated: true)
                }
                alert.addAction(deleteAction)
                alert.addAction(cancelAction)
                
                self.present(alert, animated: true)
            }
            
            return UIMenu(children: [editAction, deleteAction])
        }
    }
}

extension CategoryViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categoriesCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "categoryCell")
        guard let categoryName = viewModel.categoryName(at: indexPath) else { return UITableViewCell() }
        let isSelected = viewModel.isCategorySelected(at: indexPath)
        cell.textLabel?.text = categoryName
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.accessoryType = isSelected ? .checkmark : .none
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        cell.backgroundColor = .backgroundDay.withAlphaComponent(0.3)
        
        cell.selectionStyle = .none
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width + 100)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        return cell
    }
}
