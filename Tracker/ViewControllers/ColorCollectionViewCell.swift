import UIKit

final class ColorCollectionViewCell:UICollectionViewCell {
    
    static let reuseIdentifier = "ColorCollectionViewCell"
    
    private let colorView = UIView()
    private let selectionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.layer.cornerRadius = 8
        view.backgroundColor = .clear
        view.layer.borderWidth = 3
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    private func setupUI(){
        colorView.layer.cornerRadius = 8
        colorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(selectionView)
        contentView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            colorView.heightAnchor.constraint(equalToConstant: 38),
            colorView.widthAnchor.constraint(equalToConstant: 38),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            selectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            selectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func configure(color: UIColor){
        colorView.backgroundColor = color
        selectionView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
    }
    
    func changeSelection(_ isSelected: Bool) {
        selectionView.isHidden = !isSelected
    }
}
