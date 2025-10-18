import UIKit

final class PrimaryButtonView: UIView {
    var onTap: (() -> Void)?
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var icon: UIImage? {
        didSet {
            uiImage.image = icon
        }
    }
    
    var isDisabled: Bool = false {
        didSet {
            backgroundColor = isDisabled ? .primaryS2 : .primaryS1
        }
    }
    
    private var titleLabel = { label in
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .appBar
        return label
    }(UILabel())
    
    private var uiImage = { image in
        image.translatesAutoresizingMaskIntoConstraints = false
        image.widthAnchor.constraint(equalToConstant: 16).isActive = true
        image.heightAnchor.constraint(equalToConstant: 16).isActive = true
        image.tintColor = .appBar
        return image
    }(UIImageView())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configurateUI()
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(recognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError( "init(coder:) has not been implemented" )
    }
    
    private func configurateUI() {
        backgroundColor = .primaryS1
        layer.cornerRadius = 8
        
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 16
        stack.distribution = .fill
      
        stack.addArrangedSubview(uiImage)
        stack.addArrangedSubview(titleLabel)
        
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    @objc private func handleTap() {
        guard !isDisabled else { return }
        onTap?()
    }
}
