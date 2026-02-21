import UIKit

final class NewCategoryViewController: UIViewController{
    private let textField = TextFieldWithPadding()
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .gray
        button.isEnabled = false
        button.layer.cornerRadius = 16
        return button
    }()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .redWarning
        label.textAlignment = .center
        label.text = "Ограничение 38 символов"
        label.isHidden = true
        return label
    }()
    
    private let maxLength = 38
    private let viewModel: TrackerViewModel
    
    init(viewModel: TrackerViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Новая категория"
        setupNavigationController()
        setupTextFieldAndWarningLabel()
        setupDoneButton()
        setupTapGesture()
    }
    
    private func setupNavigationController(){
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.blackDay,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.blackDay,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    private func setupDoneButton(){
        doneButton.addTarget(self, action: #selector(doneButtonTaped), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupTextFieldAndWarningLabel(){
        textField.delegate = self
        textField.clipsToBounds = true
        textField.placeholder = "Введите название категории"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .whileEditing
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        view.addSubview(warningLabel)
        
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            warningLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            warningLabel.centerXAnchor.constraint(equalTo: textField.centerXAnchor)
        ])
    }
    
    private func updateDoneButton(isEnabled: Bool) {
        doneButton.isEnabled = isEnabled
        doneButton.backgroundColor = isEnabled ? .blackDay : .gray
    }
    
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func doneButtonTaped(){
        guard let categoryName = textField.text else { return }
        viewModel.addCategory(name: categoryName)
        dismiss(animated: true)
    }
}

extension NewCategoryViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        let isNotEmpty = !updatedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        updateDoneButton(isEnabled: isNotEmpty)
        
        
        let isOverLimit = updatedText.count >= maxLength
        warningLabel.isHidden = !isOverLimit
        return updatedText.count <= maxLength
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        updateDoneButton(isEnabled: false)
        return true
    }
}
