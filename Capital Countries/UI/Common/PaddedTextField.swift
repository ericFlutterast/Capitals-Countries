import UIKit

final class PaddedTextField: UITextField {
    private var _padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    var padding: UIEdgeInsets {
        get { _padding }
        set {
            _padding = newValue
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: _padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: _padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: _padding)
    }
}
