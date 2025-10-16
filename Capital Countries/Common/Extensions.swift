import UIKit

extension UIView{
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            responder = responder?.next
            if let controller = responder as? UIViewController {
                return controller
            }
        }
        return nil
    }
}
