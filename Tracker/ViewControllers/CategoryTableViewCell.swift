import UIKit

class CategoryTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "CategoryTableViewCell"
    
    let textField: UITextField = {
        let tf = UITextField()
        tf.isUserInteractionEnabled = false
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = .systemFont(ofSize: 17)
        tf.returnKeyType = .done
        return tf
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with text: String, isSelected: Bool) {
        textField.text = text
        accessoryType = isSelected ? .checkmark : .none
    }
}
