import UIKit

class StatCardView: UIView {
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()
    private let gradientLayer = CAGradientLayer()
    
    init(value: String, title: String) {
        super.init(frame: .zero)
        setupUI(value: value, title: title)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI(value: String, title: String) {
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 34, weight: .bold)
        valueLabel.textColor = .blackDay
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12,weight: .medium)
        titleLabel.textColor = .blackDay
        
        let stack = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        stack.axis = .vertical
        stack.spacing = 7
        addSubview(stack)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
        
        layer.cornerRadius = 16
        addGradientBorder()
    }
    
    private func addGradientBorder() {
        gradientLayer.colors = [
            UIColor.gradientBlue.cgColor,
            UIColor.gradientGreen.cgColor,
            UIColor.gradientRed.cgColor
        ]
        
        gradientLayer.locations = [0, 0.5, 1]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        layer.addSublayer(gradientLayer)
        
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        shape.path = UIBezierPath(roundedRect: bounds, cornerRadius: 16).cgPath
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shape
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        (gradientLayer.mask as? CAShapeLayer)?.path = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
    }
}
