import UIKit

protocol TrackerCollectionViewCellProtocol: AnyObject {
    func increaceDaysCount(in cell: TrackerCollectionViewCell)
    func decreaceDaysCount(in cell: TrackerCollectionViewCell)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "CustomTrackerCell"
    
    weak var delegate: TrackerCollectionViewCellProtocol?
    
    private let upperView = UIView()
    private let lowerView = UIView()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16,weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let daysLabel: UILabel = {
        let label = UILabel()
        label.textColor = .blackDay
        label.font = UIFont.systemFont(ofSize: 12,weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let plusButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark"), for: .selected)
        button.tintColor = .white
        button.layer.cornerRadius = 17
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellAppearance()
        setupSubviews()
        setupConstraints()
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        daysLabel.text = "1 день"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupCellAppearance() {
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        
        upperView.layer.cornerRadius = 16
        upperView.translatesAutoresizingMaskIntoConstraints = false
        lowerView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupSubviews() {
        contentView.addSubview(upperView)
        upperView.addSubview(emojiBackgroundView)
        emojiBackgroundView.addSubview(emojiLabel)
        upperView.addSubview(titleLabel)
        
        contentView.addSubview(lowerView)
        lowerView.addSubview(daysLabel)
        lowerView.addSubview(plusButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            upperView.topAnchor.constraint(equalTo: contentView.topAnchor),
            upperView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            upperView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            upperView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiBackgroundView.topAnchor.constraint(equalTo: upperView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: upperView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            
            //titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: upperView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: upperView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: upperView.bottomAnchor, constant: -12),
            
            lowerView.topAnchor.constraint(equalTo: upperView.bottomAnchor),
            lowerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            lowerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            lowerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            daysLabel.leadingAnchor.constraint(equalTo: lowerView.leadingAnchor, constant: 12),
            daysLabel.topAnchor.constraint(equalTo: lowerView.topAnchor, constant: 16),
            daysLabel.bottomAnchor.constraint(equalTo: lowerView.bottomAnchor, constant: -24),
            
            plusButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            plusButton.centerYAnchor.constraint(equalTo: daysLabel.centerYAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(tracker: Tracker, isCompleted: Bool, completionCount: Int, isFuture: Bool) {
        titleLabel.text = tracker.title
        emojiLabel.text = tracker.emoji
        upperView.backgroundColor = tracker.color
        plusButton.backgroundColor = tracker.color
        plusButton.isSelected = isCompleted
        plusButton.alpha = isCompleted ? 0.3 : 1.0
        if isFuture{
            plusButton.isEnabled = false
            plusButton.alpha = 0.3
        }else{
            plusButton.isEnabled = true
        }
        daysLabel.text = "\(completionCount) дней"
    }
    
    //MARK: - Button action
    
    @objc private func plusButtonTapped() {
        if plusButton.isSelected == false{
            plusButton.isSelected = true
            plusButton.alpha = 0.3
            delegate?.increaceDaysCount(in: self)
        }else{
            plusButton.isSelected = false
            plusButton.alpha = 1.0
            delegate?.decreaceDaysCount(in: self)
        }
    }
}

