import UIKit

/// Stores transition context state during presentation and dismissal
/// of a modal card transition
class ModalCardTransitionContext {
    let transitionContext: UIViewControllerContextTransitioning
    let contentContainerView: UIView
    let overlayView: UIView
    let panGestureRecognizer: UIPanGestureRecognizer
    let endpoint: CGFloat
    var exceedsEndpoint: Bool = true

    init(transitionContext: UIViewControllerContextTransitioning, contentContainerView: UIView, overlayView: UIView, gestureRecognizer: UIPanGestureRecognizer, endpoint: CGFloat) {
        self.transitionContext = transitionContext
        self.contentContainerView = contentContainerView
        self.overlayView = overlayView
        self.panGestureRecognizer = gestureRecognizer
        self.endpoint = endpoint
    }
}
