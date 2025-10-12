import UIKit

final class IconButtonView: UIView {
    var onTap: (()-> Void)?
    
    var icon: UIImage? {
        didSet{
            uiImageView.image = icon!
        }
    }
    
    
    private var size: CGFloat!
    
    private var uiImageView = { uiImageView in
        uiImageView.translatesAutoresizingMaskIntoConstraints = false
        return uiImageView
    }(UIImageView())

    convenience init(onTap: (() -> Void)? = nil, icon: UIImage? = nil, size: CGFloat = 52) {
        self.init()
        
        self.onTap = onTap
        self.uiImageView.image = icon
        self.size = size
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.size = 52
        configurateUI()
        let gestureRcognizer = UITapGestureRecognizer(target: self, action: #selector(onTapHandler))
        addGestureRecognizer(gestureRcognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError( "init(coder:) has not been implemented" )
    }
    
    private func configurateUI() {
        heightAnchor.constraint(equalToConstant: size).isActive = true
        widthAnchor.constraint(equalToConstant: size).isActive = true
        tintColor = .textPrimary
        
        layer.cornerRadius = 8
        layer.borderColor = UIColor.border.cgColor
        layer.borderWidth = 1
        
        addSubview(uiImageView)
        NSLayoutConstraint.activate([
            uiImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            uiImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    @objc private func onTapHandler() {
        onTap?()
    }
}
