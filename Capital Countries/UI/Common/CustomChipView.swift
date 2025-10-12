import UIKit

final class CustomChipView: UIView{
    var title: String? {
        didSet {
            titleLabelView.text = title
        }
    }
    
    lazy var titleLabelView = { label in
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .textPrimary
        label.textAlignment = .center
        return label
    } (UILabel())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configurateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError( "init(coder:) has not been implemented" )
    }
    
    private func configurateUI() {
        layer.cornerRadius = 8
        layer.borderColor = UIColor.border.cgColor
        layer.borderWidth = 1
        
        addSubview(titleLabelView)
        NSLayoutConstraint.activate([
            titleLabelView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            titleLabelView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            titleLabelView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            titleLabelView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
        ])
    }
}
