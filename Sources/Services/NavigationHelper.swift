import UIKit

// 🚀 Enabling Interactive Pop Gesture (Swipe to Back) when navigation bar is hidden.
// Since we use .navigationBarHidden(true) to maintain the skeuomorphic UI, 
// the system disables the swipe gesture by default. This extension re-enables it.

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
