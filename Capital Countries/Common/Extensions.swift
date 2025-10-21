import UIKit

extension UIView {
    func findUiViewController<T: UIViewController>(ofType type: T.Type, selfResponder: Bool = false) -> T? {
        var responder = selfResponder ? self : self.next
        while responder != nil {
            if let controller = responder as? T {
                return controller
            }
            responder = responder?.next
        }
        
        return nil
    }
}
